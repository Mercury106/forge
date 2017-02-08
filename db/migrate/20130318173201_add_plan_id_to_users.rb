class AddPlanIdToUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      if user.stripe_customer_token
        user.plan_id = 'basic'
      else
        user.plan_id = 'free'
      end
      user.save
    end
  end
end
