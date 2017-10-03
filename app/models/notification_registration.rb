class NotificationRegistration < ApplicationRecord
  def register_sns
    sns = Aws::SNS::Client.new(region: 'us-west-2')
    user = self.user_id.nil? ? nil : User.find(self.user_id)
    topics = []
    topics << 'volunteers' unless user.nil?
    topics << 'sc' if user.has_role?('SiteCoordinator')
    topics.each do |t|
        topic_arn = case t
          when 'volunteers'
            Rails.configuration.sns_topic_volunteers_arn
          when 'sc'
            Rails.configuration.sns_topic_sc_arn
          end
        sns_app_arn = case self.platform
          when 'android'
            Rails.configuration.sns_gcm_application_arn
          when 'ios'
            Rails.configuration.sns_apn_application_arn
          when 'sms'
            user.nil? ? '' : user.phone
          else
            ''
          end

        response = sns.subscribe({
            topic_arn: topic_arn,
            protocol: 'application',
            endpoint: sns_app_arn
        })
        logger.info("SNS subscription: #{response}")
    end
  end
end
