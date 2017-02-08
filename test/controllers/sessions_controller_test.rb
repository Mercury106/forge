require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  ## Sessions controller for billing.
  ## This controller tests the way we set up and cancel subscriptions.
  ## We use the session, using stripe_card_token tied to the session.
  ## The session endpoint actually represents the current user. 
  ## This should be renamed at some point and we'll need to move these around, I'm sure.

  setup :initialize_user
  teardown :destroy_user

  # When hitting :update with the stripe_card_token parameter, 
  # they're saying "save my subscription and charge me."
  context "when saving a valid card for the first time" do
    setup do
      VCR.insert_cassette "stripe-creating"
      put :update, valid_session_parameters

      @user.reload()
    end

    should "leave the user with an active subscription" do
      assert @user.subscription_active
    end

    should "put the user on the basic plan" do
      assert_equal 'basic', @user.reload().plan_id
    end

    should "succeed" do
      assert_response :success
    end

    teardown do
      VCR.eject_cassette
    end
  end

  context "when cancelling the subscription" do
    setup do
      VCR.insert_cassette "stripe-cancelling"
      give_user_a_valid_card
      put :update, {session: {subscription_active: false, plan_id: 'free'}, id: 1}
    end

    should "succeed" do
      assert_response :success
    end

    should "put the user on the free plan" do
      assert_equal 'free', @user.reload().plan_id
    end

    should "leave the user without an active subscription" do
      assert !@user.reload().subscription_active
    end

    teardown do
      VCR.eject_cassette
    end
  end

  context "when updating the subscription" do
    setup do
      VCR.insert_cassette "stripe-updating"

      @user.stripe_card_token = valid_old_dummy_token.id
      @user.country = 'United Kingdom'
      @user.process_billing
      @user.save
      @old_token = @user.stripe_customer_token

      put :update, valid_session_parameters
    end

    should "succeed" do
      assert_response :success
    end

    should "leave the user with an active subscription" do
      assert @user.subscription_active
    end

    should "not change customer token" do
      assert @old_token, "old token should not be nil"
      @user.reload()
      assert_not_nil @user.stripe_customer_token
      assert_equal @user.stripe_customer_token, @old_token
    end

    teardown do
      VCR.eject_cassette
    end
  end

private

  def valid_session_parameters
    {
      session: { stripe_card_token: valid_dummy_token.id,
                 country: 'United Kingdom',
                 plan_id: 'basic' },
      id: 1
    }
  end

  def valid_dummy_token
    @valid_dummy_token ||= Stripe::Token.create(
      :card => {
        :number => "4242424242424242",
        :exp_month => 9,
        :exp_year => (Date.today.year + 1),
        :cvc => "314"
      }
    )
  end

  def valid_old_dummy_token
    @valid_old_dummy_token ||= Stripe::Token.create(
      :card => {
        :number => "4242424242424242",
        :exp_month => 11,
        :exp_year => (Date.today.year + 2),
        :cvc => "456"
      }
    )
  end

  def insert_cassette
    VCR.insert_cassette 'stripe'
  end

  def eject_cassette
    VCR.eject_cassette
  end

  def initialize_user
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  def destroy_user
    @user.destroy()
  end

  def give_user_a_valid_card
    @user.plan_id = 'basic'
    @user.country = 'United Kingdom'
    @user.stripe_card_token = valid_dummy_token.id
    @user.save()
  end

end