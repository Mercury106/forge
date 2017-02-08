class WelcomeMailer < ActionMailer::Base
  default from: "Forge <admin@getforge.com>"

  def welcome(user_id)
    @user = User.find(user_id)
  end
end
