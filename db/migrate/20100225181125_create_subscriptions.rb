class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :type
      t.string :name
    end
    
    Subscription.enumeration_model_updates_permitted = true
    Subscription.create(:name => 'free', :type => 1)
    Subscription.create(:name => 'moderated', :type => 2)
    Subscription.create(:name => 'key_only', :type => 3)
    Subscription.create(:name => 'pay_only', :type => 4)
    Subscription.create(:name => 'key_and_pay', :type => 5)
    
    Subscription.enumeration_model_updates_permitted = false
    
    add_column :schools, :subscription_id, :integer
    
     #set all existing schools to 'free'
    School.update_all("subscription_id = 1")
    
    
  end

  def self.down
    drop_table :subscriptions
    remove_column :schools, :subscription_id
  end
end
