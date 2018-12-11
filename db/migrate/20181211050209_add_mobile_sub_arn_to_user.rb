class AddMobileSubArnToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :mobile_subscription_arn, :string
    add_column :sites, :sns_topic, :string
  end
end
