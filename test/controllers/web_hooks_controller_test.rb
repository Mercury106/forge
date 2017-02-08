require 'test_helper'

class WebHooksControllerTest < ActionController::TestCase

  context "receiving a webhook matching a customer" do

    setup do
      VCR.insert_cassette 'stripe-invoices'
      VersionDeployer.any_instance.stubs(:deploy_slug).returns("deploy-slug")
      Site.any_instance.stubs(:generate_first_version).returns(true)
    end

    teardown  { VCR.eject_cassette }
    setup  do
      @user = FactoryGirl.build(:user, stripe_customer_token: StripeDummyConstants['customer_token'], country: "United States of America", :plan_id => "basic")
      stripe_customer = Object.new
      stripe_customer.stubs(:email).returns(@user.email)
      stripe_customer.stubs(:update_subscription).with(:plan => 'basic').returns(true)
      Stripe::Customer.stubs('retrieve').with("customer_token").returns(stripe_customer)
      @user.save()
    end

    ## When invoices are created

    # We're expecting to create a set of line items when an invoice is created.
    # If they're not using the base amount of data, we'll just send
    #    10GB free data: $10

    # If they go over that, we'll send
    #     2GB paid bandwdith: $0.40
    #     10GB free data: $10

    # In future, we should change this so that we get a real output of what bandwidth you use for which site,
    # including a discount of <= $10 (plan price) for the first <= 10GB of data.

    context "When an invoice is created" do
      setup do
        Stripe::InvoiceItem.expects(:create).with({
          :customer => @user.stripe_customer_token,
          :description => "10 GB free bandwidth",
          :amount => 0,
          :currency => "usd",
          :invoice => StripeDummyConstants['invoice_id']
        }).returns(true)

        @mockInvoice = Object.new
        @mockInvoice.stubs(:id).returns(StripeDummyConstants['invoice_id'])
        @mockInvoice.stubs(:closed).returns(false)
        @mockInvoice.stubs(:refresh).returns(@mockInvoice)
        @mockInvoice.stubs(:total).returns(1000)
        @mockInvoice.stubs(:subtotal).returns(1000)
        Stripe::Invoice.expects(:retrieve).with(StripeDummyConstants['invoice_id']).returns(@mockInvoice)
      end

      should "add invoice items to the user's next invoice" do
        post :incoming, StripeDummyData['invoice.created']
      end

      context "when the user has a site with some bandwidth" do
        setup do
          @site = FactoryGirl.create(:site, :user_id => @user.id)
          @site.add_usage 12.gigabytes, Time.at(StripeDummyConstants['period_start']) + 2.days
        end

        # context "when a user is VAT registered" do
        #   setup do
        #     @user.country = "United Kingdom"
        #     @user.save
        #   end

        #   should "charge the invoice with VAT included" do

        #     Stripe::InvoiceItem.expects(:create).with({
        #       :customer => @user.stripe_customer_token,
        #       :description => "2 GB paid bandwidth",
        #       :amount => 40,
        #       :currency => "usd",
        #       :invoice => StripeDummyConstants['invoice_id']
        #     }).returns(true)

        #     Stripe::InvoiceItem.expects(:create).with({
        #       :customer => @user.stripe_customer_token,
        #       :description => "VAT at 20%",
        #       :amount => 208,
        #       :currency => "usd",
        #       :invoice => StripeDummyConstants['invoice_id']
        #     }).returns(true)

        #     @mockInvoice.stubs(:total).returns(1040)
        #     @mockInvoice.stubs(:subtotal).returns(1040)

        #     post :incoming, StripeDummyData['invoice.created']
        #   end
        # end

        context "and an invoice is created" do
          should "make a Stripe call for each line item we're adding." do
            Stripe::InvoiceItem.expects(:create).with({
              :customer => @user.stripe_customer_token,
              :description => "2 GB paid bandwidth",
              :amount => 40,
              :currency => "usd",
              :invoice => StripeDummyConstants['invoice_id']
            }).returns(true)

            post :incoming, StripeDummyData['invoice.created']
            assert_equal @user.unbilled_usage, 0
          end
        end
      end

      context "when the user has a site without bandwidth" do
        setup do
          @site = FactoryGirl.create(:site, :user_id => @user.id)
          @site.add_usage 2.gigabytes, Time.at(StripeDummyConstants['period_start']) + 1.hour
        end

        # context "when a user is VAT registered" do
        #   setup do
        #     @user.country = "United Kingdom"
        #     @user.save
        #   end

        #   should "charge the invoice with VAT included" do
        #     Stripe::InvoiceItem.expects(:create).with({
        #       :customer => @user.stripe_customer_token,
        #       :description => "VAT at 20%",
        #       :amount => 200,
        #       :currency => "usd",
        #       :invoice => StripeDummyConstants['invoice_id']
        #     }).returns(true)

        #     post :incoming, StripeDummyData['invoice.created']
        #   end
        # end

        context "and an invoice is created" do
          should "make a Stripe call for each line item we're adding." do
            post :incoming, StripeDummyData['invoice.created']
            assert_equal @user.unbilled_usage, 0
          end
        end
      end
    end


    ## Deleting a subscription (from inside Stripe) causes a webhook to be sent to us.
    # This should delete the subscription from the user.

    context "When a subscription is deleted" do
      setup do
        assert @user.reload.subscription_active
        post :incoming, StripeDummyData['customer.deleted']
      end

      should "leave the user without an active subscription" do
        assert !@user.reload.subscription_active
      end
    end

    context "When a subscription is created" do
      should "add the subscription to the relevant user!" do
        @user = FactoryGirl.create(:user)
        stripe_user = mock
        stripe_user.expects(:email).at_least_once.returns(@user.email)

        Stripe::Customer.expects(:retrieve).returns(stripe_user)

        post :incoming, StripeDummyData['customer.subscription_created']
        assert_equal StripeDummyConstants['customer_token'], @user.reload().stripe_customer_token
      end
    end


    ## Payments that go through, or don't go through.
    # Payment and failure are our options here.
    # If the payment succeeds, we send a receipt. If the payment fails,
    # we send a reminder email.

    context "when a payment succeeds" do
      should "send the 'receipt' email to the user, notifying them of the receipt." do
        InvoiceMailer.expects(:receipt).once.returns(stub(:deliver))
        post :incoming, StripeDummyData['invoice.payment_succeeded']
      end
    end

    context "when a payment fails" do
      should "send the 'payment_failed' email to tell them to update their shit." do
        InvoiceMailer.expects(:payment_failed).once.returns(stub(:deliver))
        post :incoming, StripeDummyData['invoice.payment_failed']
      end
    end


  end
end