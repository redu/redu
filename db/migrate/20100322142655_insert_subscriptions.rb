class InsertSubscriptions < ActiveRecord::Migration
  def self.up
    Subscription.delete_all
    
    Subscription.enumeration_model_updates_permitted = true
    @sub = Subscription.new   # TODO por que só está funcionando assim??
    @sub.type = 1
    @sub.name = "free"
    @sub.save
    
    @sub = Subscription.new
    @sub.type = 2
    @sub.name = "moderated"
    @sub.save
    
#    Subscription.create(:name => 'free', :type => 1)
#    Subscription.create({:type => 2, :name => 'moderated'} )
#    Subscription.create(:name => 'key_only', :type => 3)
#    Subscription.create(:name => 'pay_only', :type => 4)
#    Subscription.create(:name => 'key_and_pay', :type => 5)
    Subscription.enumeration_model_updates_permitted = false
    
    School.update_all("subscription_id = 1")
  end

  def self.down
  end
end
