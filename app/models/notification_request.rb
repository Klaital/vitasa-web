class NotificationRequest < ApplicationRecord
  belongs_to :organization

    VALID_AUDIENCES = %w{ volunteers sc }
    validates :audience, inclusion: { 
        in: VALID_AUDIENCES,
        message: "%{value} is not a valid audience. Must be one of #{VALID_AUDIENCES.join(', ')}" 
    }


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
                          'arn:aws:sns:us-west-2:813809418199:vita-#{Rails.env}-#{self.organization_id}-notification-volunteers'
                        when 'sc'
                          'arn:aws:sns:us-west-2:813809418199:vita-notification-sc'
                        else
                          nil
                        end
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
            end
        rescue => exception
            return nil
        end

        return false
    end
end
