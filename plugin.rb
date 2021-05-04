# frozen_string_literal: true

# name: bump-suppress
# about: Suppress topic bump
# version: 1.0
# authors: danymajeed
# url: https://github.com/danymajeed/discourse-bump-suppress

enabled_site_setting :bump_suppress

PLUGIN_NAME ||= 'BumpSuppress'

after_initialize do

  if SiteSetting.bump_suppress

    #############################

    class ::PostCreator
      module SuppressTopicBump
        def update_topic_stats
          if @post.post_type == Post.types[:regular] &&
            @topic.created_at.to_time < Time.now - (3600 * SiteSetting.bump_suppress_topic_age_threshold)
            @post.no_bump = true
          end
          super
        end
      end
      prepend SuppressTopicBump
    end

    #############################

    class ::PostRevisor
      module SuppressTopicBump
        def bypass_bump?
          return true
        end
      end
      prepend SuppressTopicBump
    end

    #############################
  
  end
end
