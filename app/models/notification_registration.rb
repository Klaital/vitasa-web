class NotificationRegistration < ApplicationRecord
  belongs_to :user
  before_destroy :delete_arns

  def delete_arns
    sns = Rails.configuration.sns
    # Deregister the endpoint and subscription from the SNS application
    unless self.endpoint.nil?
      platform_endpoint = Aws::SNS::PlatformEndpoint.new(arn: self.endpoint, :client => sns)      
      platform_endpoint.delete
    end
    
    unless self.subscription.nil?
      subscription = Aws::SNS::Subscription.new(arn: self.subscription, :client => sns)
      subscription.delete
    end
  end

  def register_sns
    sns = Rails.configuration.sns
    user = self.user_id.nil? ? nil : User.find(self.user_id)

    # If the user already has a device registered, delete that Endpoint first
    NotificationRegistration.where(user_id: self.user_id).find_each do |registration|
      logger.debug("Deleting old NR: #{registration}")
      next if registration.id == self.id

      # Deregister the endpoint and subscription from the SNS application
      unless registration.endpoint.nil?
        logger.debug("Deleting old endpoint: #{registration.endpoint}")
        platform_endpoint = Aws::SNS::PlatformEndpoint.new(arn: registration.endpoint, :client => sns)      
        platform_endpoint.delete
      end
    
      unless registration.subscription.nil?
        if registration.subscription !~ /\A[0-9a-f]{8}-/
          logger.debug("Deleting old subscription: #{registration.subscription}")
          subscription = Aws::SNS::Subscription.new(arn: registration.subscription, :client => sns)
          subscription.delete
        end
      end

      # Then delete the NotificationRegistration
      registration.delete
    end

    topics = []
    topics << 'volunteers' unless user.nil?
    topics << 'sc' if user.has_role?('SiteCoordinator')

    topics << user.preferred_sites.collect {|ps| ps.get_sns_topic}
    user.roles.each do |role|
      topics << user.organization.role_topic_arn(role.name)
    end
    topics.flatten!
    
    topics.each do |t|
      protocol = 'application'
      topic_arn = case t
        when 'volunteers'
          self.user.organization.volunteers_topic_arn
        when 'sc'
          self.user.organization.site_coordinators_topic_arn
        else
          t
        end
      sns_app_arn = case self.platform
        when 'android'
          Rails.configuration.sns_gcm_application_arn
        when 'ios'
          Rails.configuration.sns_apn_application_arn
        when 'sms'
          protocol = 'sms'
          user.nil? ? '' : user.phone
        else
          ''
        end

      next if sns_app_arn.nil?


      endpoint_arn = if self.platform == 'sms'
        user.phone
      else
        # Create a handle on the releant protocol's SNS Application
        platform_application = Aws::SNS::PlatformApplication.new(arn: sns_app_arn, :client => sns)

        # Construct a new platform endpoint for this user's device
        platform_endpoint = platform_application.create_platform_endpoint({
                                                                             token: self.token
                                                                         })
        # And save it for future housekeeping
        self.endpoint = platform_endpoint.arn
        platform_endpoint.arn
      end

      # Now we register that endpoint as a subscription on the relevant topics
      logger.debug("Subscribing to Topic #{topic_arn} with endpoint #{endpoint_arn}")
      subscription = sns.subscribe({
          topic_arn: topic_arn,
          protocol: protocol,
          endpoint: endpoint_arn,
      })
      logger.info("SNS subscription: #{subscription}")

      # And also save the subscription ARN for future housekeeping
      self.subscription = subscription.subscription_arn
      self.save
    end
  end
end
