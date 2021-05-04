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
          attrs = { updated_at: Time.now }
          if @post.post_type != Post.types[:whisper] && !@opts[:silent]
              attrs[:last_posted_at] = @post.created_at
              attrs[:last_post_user_id] = @post.user_id
              attrs[:word_count] = (@topic.word_count || 0) + @post.word_count
              attrs[:excerpt] = @post.excerpt_for_topic if new_topic?
              if @topic.created_at.to_time > Time.now - (3600 * SiteSetting.disable_bump_for)
                attrs[:bumped_at] = @post.created_at
              end
          end
          @topic.update_columns(attrs)
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
