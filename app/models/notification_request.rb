class NotificationRequest < ApplicationRecord
  belongs_to :organization

    VALID_AUDIENCES = %w{ volunteers sc }
    validates :audience, presence: true, format: { with: /\A(volunteers|sc|role-.*)\Z/, message: "%{value} is not a valid audience. Must be one of 'volunteers, 'sc', and 'role-$rolename'"}

    def send_broadcast
        unless self.sent.nil?
            return false
        end

        begin
          sns = Rails.configuration.sns
          message = {
            :default => self.message,
            :aps => { :alert => self.message },
            :gcm => {
              :notification => {
                :text => self.message,
#                    :click_action => "A_ViewNotification" 
              }
            }.to_json
          }.to_json
          topic_arn = case self.audience.to_s.downcase
                      when 'volunteers'
                        self.organization.volunteers_topic_arn
                      when 'sc'
                        self.organization.site_coordinators_topic_arn
                      when /role-/
                        role_name = self.audience.to_s.split('-')[1].downcase
                        self.organization.role_topic_arn(role_name)
                      else
                        nil
                      end
          logger.debug("Sending message to Topic #{topic_arn}")
          response = sns.publish({
              :topic_arn => topic_arn,
              :message => message,
              :message_structure => 'json'
          })

          if response.message_id
            self.sent = Time.now
            self.message_id = response.message_id
            self.save
            return self.message_id
          else
            logger.error("No message ID in response: #{response}")
          end
        rescue => exception
          logger.error("Failed to send broadcast: #{exception}")
          self.organization.create_sns_topics
          return nil
        end

        logger.error("Failed to send broadcast")
        return false
    end
end
