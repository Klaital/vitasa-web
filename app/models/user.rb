class User < ApplicationRecord
  has_many :role_grants
  has_many :roles, through: :role_grants
  
  before_save do
    self.email = email.downcase

    # By default, users should get the NewUser role, which restricts them from
    # modifying anything until an Admin approves them.
    if self.roles.empty?
      self.roles = [ Role.find_by(name: 'NewUser') ]
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

  # Returns the hash digest of the given string.
  def User.digest(s)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
    BCrypt::Password.create(s, cost: cost)
  end

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
end

