class User < ApplicationRecord
  has_many :role_grants
  has_many :roles, through: :role_grants
  has_many :work_logs
  after_create :email_notify_admins

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
    admins.each do |user|
      begin
        SesMailer.new_user_email(:recipient => user, :new_user => @user).deliver
      rescue Net::SMTPFatalError => e
        logger.error "Failed to send email to #{user.email}"
        next
      end
    end
  end
end

