class NotificationRegistration < ApplicationRecord
  def register_sns
    sns = Aws::SNS::Client.new(region: 'us-west-2')
    user = self.user_id.nil? ? nil : User.find(self.user_id)
    topics = []
    topics << 'volunteers' unless user.nil?
    topics << 'sc' if user.has_role?('SiteCoordinator')
    topics.each do |t|
        topic_arn = "arn:aws:sns:us-west-2:813809418199:vita-notification-#{t}"
        response = sns.subscribe({
            topic_arn: topic_arn,
            protocol: self.platform.downcase,
            endpoint: self.token
        })
    end
  end
end
