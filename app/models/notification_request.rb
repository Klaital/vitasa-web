class NotificationRequest < ApplicationRecord
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
            sns = Aws::SNS::Client.new(region: 'us-west-2')
            response = sns.publish({
                topic_arn: topic_arn = "arn:aws:sns:us-west-2:813809418199:vita-notification-#{self.audience}",
                message: self.message
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
