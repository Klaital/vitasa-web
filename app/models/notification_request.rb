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
            message = {
                :default => self.message,
                :aps => { :alert => self.message },
                :gcm => { :notification => { :text => self.message } }
            }.to_json
            response = sns.publish({
                :topic_arn => topic_arn,
                :message => self.message,
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
