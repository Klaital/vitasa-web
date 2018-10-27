class User < ApplicationRecord
  has_many :role_grants
  has_many :roles, through: :role_grants
  has_many :signups
  
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

  VALID_CERTIFICATION_LEVELS = %w{ None Basic Advanced SiteCoordinator }
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

  # Sites managed
  def sites_coordinated
    Site.select('id, slug, name').where('sitecoordinator = ? or backup_coordinator_id = ?', self.id, self.id)
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


  def work_history
    Signup.where(
        :user_id => self.id
      ).joins(
        :shift => :calendar
      ).where(
        'calendars.date < ?', Date.today
      )
  end

  def work_intents
    Signup.where(
        :user_id => self.id
      ).joins(
        :shift => :calendar
      ).where(
        'calendars.date >= ?', Date.today
      )
  end
  
  def suggestions
    Suggestion.where(user_id: self.id)
  end
end

