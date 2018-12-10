class SesMailer < ApplicationMailer
  def new_user_email(options={})
    @new_user = options[:new_user]
    # admin_grants = RoleGrant.where(role_id: Role.find_by(name: 'Admin').id)
    # @admins = User.where(user_id: admin_grants.collect{|g| g.user_id})
    @recipient = options[:recipient]
    mail(:to => @recipient.email, :subject => 'New User Registration')
  end

  def new_suggestion_email(options={})
    @new_suggestion = options[:suggestion]
    @recipient = options[:recipient]
    mail(:to => @recipient.email, :subject => 'New Suggestion')
  end
end
