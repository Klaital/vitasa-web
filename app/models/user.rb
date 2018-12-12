class User < ApplicationRecord
  has_many :role_grants
  has_many :roles, through: :role_grants
  has_many :work_logs
  after_create :email_notify_admins
  before_save :register_mobile_updates

  after_initialize do
    subscribe_mobile = false if subscribe_mobile.nil?
  end

  # has_many :preferred_sites, :class_name => 'Site', :through => :preferred_sites
  has_and_belongs_to_many :preferred_sites, :class_name => 'Site', :join_table => 'preferred_sites'
  has_and_belongs_to_many :sites_coordinated, class_name: 'Site', join_table: 'users_sites'
  
  before_save do
    self.email = email.downcase

    # By default, users should get the NewUser role, which restricts them from
    # modifying anything until an Admin approves them.
    if self.roles.empty?
      self.roles = [ Role.find_by(name: 'Volunteer') ]
    end
  end

  before_validation do
    # By default, users get no certification level
    self.certification ||= 'None'

    # Normalize the submitted phone number
    unless self.phone.nil?
      tmp = self.phone.gsub(/[^\d]/, '')
      self.phone = "#{tmp[0..2]}-#{tmp[3..5]}-#{tmp[6..-1]}"
    end
  end

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  has_secure_password
  validates :password,
            presence: true,
            length: { minimum: 6 },
            on: :create

  VALID_CERTIFICATION_LEVELS = %w{ None Greeter Basic Advanced SiteCoordinator }
  validates :certification, inclusion: { 
    in: VALID_CERTIFICATION_LEVELS,
    message: "%{value} is not a valid certification level" 
  }

  VALID_PHONE_REGEX = /\A\d{3}-\d{3}-\d{4}\z/
  validates :phone,
            format: {
              with: VALID_PHONE_REGEX,
              message: 'The phone number must have 10 digits.'
            },
            allow_blank: true


  # Returns the hash digest of the given string.
  def User.digest(s)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(s, cost: cost)
  end

  # Role queries
  def is_admin?
    self.roles.each do |role|
      return true if role.name == 'Admin'
    end
    return false
  end

  def has_role?(role_name)
    self.roles.each do |role|
      return true if role.name == role_name
    end
    return false
  end

  def suggestions
    Suggestion.where(user_id: self.id)
  end

  def self.with_role(role_name)
    role = Role.find_by(name: role_name)
    if role.nil?
      return []
    end
    grants = RoleGrant.where(role_id: role.id)
    if grants.empty?
      return []
    end

    User.where(id: grants.collect{|g| g.user_id})
  end

  def email_notify_admins
    # notify admins via email
    admins = User.with_role('Admin')
    admins.each do |admin|
      begin
        SesMailer.new_user_email(:recipient => admin, :new_user => self).deliver
      rescue Net::SMTPFatalError => e
        logger.error "Failed to send email to #{admin.email}: #{e}"
        next
      end
    end
  end

  def register_mobile_updates
    if self.subscribe_mobile_changed?
      sns = Aws::SNS::Client.new(region: 'us-west-2')
      if self.subscribe_mobile
        sns_app_arn = case self.platform
                      when 'android'
                        Rails.configuration.sns_gcm_application_arn
                      when 'ios'
                        Rails.configuration.sns_apn_application_arn
                      end
        # Pull up the most recent endpoint for this user
        platform_endpoint = NotificationRegistration.where(user_id: self.id).last.endpoint
        # Now we register that endpoint set as a subscription on the relevant topics
        subscription = sns.subscribe({
            topic_arn: topic_arn,
            protocol: 'application',
            endpoint: platform_endpoint.arn
        })
        logger.info("SNS subscription: #{subscription}")
        self.mobile_subscription_arn = subscription.subscription_arn
      else
        # Unsubscribe from updates on mobile sites
        unless self.mobile_subscription_arn.nil?
          sns.unsubscribe(subscription_arn: self.mobile_subscription_arn)
          self.mobile_subscription_arn = nil
        end
      end
    end
  end
end

