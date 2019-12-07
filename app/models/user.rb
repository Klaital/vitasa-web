class User < ApplicationRecord
  has_many :role_grants
  has_many :roles, through: :role_grants
  has_many :certification_grants
  has_many :certifications, through: :certification_grants

  has_many :work_logs
  after_create :email_notify_admins
  before_save :register_notification_updates
  belongs_to :organization

  after_initialize do
    self.subscribe_mobile = false if self.subscribe_mobile.nil?
  end

  # has_many :preferred_sites, :class_name => 'Site', :through => :preferred_sites
  has_and_belongs_to_many :preferred_sites, class_name: 'Site', join_table: 'preferred_sites'
  has_and_belongs_to_many :sites_coordinated, class_name: 'Site', join_table: 'users_sites'

  before_save do
    self.email = email.downcase.strip

    # By default, users should get the NewUser role, which restricts them from
    # modifying anything until an Admin approves them.
    if self.roles.empty?
      self.roles = [Role.find_by(name: 'Volunteer')]
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


    self.military_certification = false if self.military_certification.nil?
    self.hsa_certification = false if self.hsa_certification.nil?
    self.international_certification = false if self.international_certification.nil?
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

  VALID_CERTIFICATION_LEVELS = %w[None Greeter Basic Advanced SiteCoordinator].freeze
  validates :certification, inclusion: {
    in: VALID_CERTIFICATION_LEVELS,
    message: '%{value} is not a valid certification level'
  }

  VALID_PHONE_REGEX = /\A\d{3}-\d{3}-\d{4}\z/
  validates :phone,
            format: {
              with: VALID_PHONE_REGEX,
              message: 'The phone number must have 10 digits.',
            },
            allow_blank: true


  # Returns the hash digest of the given string.
  def self.digest(s)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(s, cost: cost)
  end

  # Role queries
  def is_admin?
    roles.each do |role|
      return true if role.name == 'Admin'
    end

    # Role not found for user
    false
  end

  # Check whether a user has any of the specified role names.
  # Can be either a single role name, or an array of many. If any in the set of
  # requested roles match any of the user's role set, return true.
  def has_role?(role_name)
    role_name = [role_name] unless role_name.kind_of?(Array)
    roles.each do |role|
      return true if role_name.include?(role.name)
    end

    # None of the requested roles found for user
    false
  end

  def has_admin?(organization_id)
    has_role?('SuperAdmin') || (self.organization_id == organization_id && has_role?(['Admin']))
  end

  def suggestions
    Suggestion.where(user_id: self.id)
  end

  def self.with_role(role_name)
    role = Role.find_by(name: role_name)

    return [] if role.nil?
    grants = RoleGrant.where(role_id: role.id)
    return [] if grants.empty?

    User.where(id: grants.collect(&:user_id))
  end

  def email_notify_admins
    # notify admins via email
    admins = User.with_role('Admin')
    admins.each do |admin|
      begin
        SesMailer.new_user_email(recipient: admin, new_user: self).deliver
      rescue Net::SMTPFatalError => e
        logger.error "Failed to send email to #{admin.email}: #{e}"
        next
      end
    end
  end

  def register_mobile_subscription(device)
    return false if device.nil?

    sns = Rails.configuration.sns
    if self.subscribe_mobile
      protocol = case device.platform
                    when 'sms'
                      'sms'
                    else
                      'application'
                    end

      # Now we register that endpoint set as a subscription on the mobile-updates topic
      subscription = sns.subscribe({
                                       topic_arn: "arn:aws:sns:us-west-2:813809418199:vs-#{Rails.env}-#{self.organization.slug}-sites-mobile",
                                       protocol: protocol,
                                       endpoint: device.endpoint,
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

  def register_notification_updates
    new_registration = if self.sms_optin
                     NotificationRegistration.where(user_id: self.id, platform: 'sms').last
                   else
                     NotificationRegistration.where(user_id: self.id, platform: %w(android ios)).last
                       end

    logger.error("No devices registered.") if new_registration.nil?

    if self.sms_optin_changed?
      if new_registration.nil?
        logger.debug "Create a device registration for the user's mobile phone #{self.phone}"
        new_registration = NotificationRegistration.new(user_id: self.id, platform: 'sms', endpoint: self.phone)
        new_registration.save
      end

      # remove all other subscriptions so that this user can use the new one
      NotificationRegistration.where(user_id: self.id).each do |device|
        next if device.id == new_registration.id
        logger.debug("Deleting old device registration: #{device}")
        device.delete
      end

      register_mobile_subscription(new_registration)

      # Re-register notifications for all subscribed sites and roles
      new_registration.register_sns
    elsif self.subscribe_mobile_changed?
      register_mobile_subscription(new_registration)
    end
  end
end

