import { withPluginApi } from "discourse/lib/plugin-api";
import discourseComputed from "discourse-common/utils/decorators";

function entranceDate(dt, showTime) {
  const today = new Date();

  if (dt.toDateString() === today.toDateString()) {
    return moment(dt).format(I18n.t("dates.time"));
  }

  if (dt.getYear() === today.getYear()) {
    // No year
    return moment(dt).format(
      showTime
        ? I18n.t("dates.long_date_without_year_with_linebreak")
        : I18n.t("dates.long_no_year_no_time")
    );
  }

  return moment(dt).format(
    showTime
      ? I18n.t("dates.long_date_with_year_with_linebreak")
      : I18n.t("dates.long_date_with_year_without_time")
  );
}

function initializeDiscourseBumpSuppress(api) {
  api.modifyClass("component:topic-entrance", {
    @discourseComputed("topic.last_posted_at")
    lastPostedAt: (last_posted_at) => new Date(last_posted_at),

    @discourseComputed("createdDate", "lastPostedAt")
    showTime(createdDate, lastPostedAt) {
      return (
        lastPostedAt.getTime() - createdDate.getTime() < 1000 * 60 * 60 * 24 * 2
      );
    },

    @discourseComputed("createdDate", "showTime")
    topDate: (createdDate, showTime) => entranceDate(createdDate, showTime),

    @discourseComputed("lastPostedAt", "showTime")
    bottomDate: (lastPostedAt, showTime) =>
      entranceDate(lastPostedAt, showTime),
  });
}

export default {
  name: "discourse-bump-suppress",

  initialize() {
    withPluginApi("0.8.31", initializeDiscourseBumpSuppress);
  },
};
