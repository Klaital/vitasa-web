class MakeSubMobileNotNull < ActiveRecord::Migration[5.0]
  def change
    User.where(:subscribe_mobile => nil).each do |u|
      u.subscribe_mobile = false
      u.save
     end
    change_column_null :users, :subscribe_mobile, false
  end
end
