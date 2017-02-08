require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "A user" do
    setup do
      @user = FactoryGirl.build(:user)
    end
    
    context "with sites" do
      setup do
        @site = FactoryGirl.build(:site, :user => @user)
        @site.expects(:unbilled_usage).returns(100.gigabytes)
        @user.sites = [@site]
      end
      
      should "calculate site bandwidth correctly" do
        assert_equal @user.unbilled_usage, 100.gigabytes
      end
    end
    
    context "when saving billing" do
      setup do
        @user.stripe_card_token = "testing123"
        @user.plan_id = 'basic'
        @user.country = 'USA'
        @customer = Stripe::Customer.new(:id => "myuserhere")
      end
      
      context "when saving" do
        setup do
          Stripe::Customer.expects(:create).with({
            email: @user.email, card: 'testing123', coupon: nil
          }).returns(@customer)
          @customer.expects(:save).returns(true)
          @user.process_billing
          @user.save()
        end
        should "save stripe customer ID without errors" do
          assert_empty @user.errors
          assert_equal "myuserhere", @user.stripe_customer_token
        end
      end
    end
    
    context "invoices" do
      setup do
        @user = FactoryGirl.build(:user, :stripe_customer_token => "myuserhere", :plan_id => 'basic')
        @customer = Stripe::Customer.new(:id => "myuserhere")
      end
      
      should "add invoice lines correctly" do
        skip "add invoice lines correctly"
        Stripe::InvoiceItem.expects(:create).with({
          :customer => "myuserhere",
          :description => "Testing",
          :amount => 10000, 
          :currency => "gbp",
          :invoice_id => "invoice_1"
        })
        @user.create_invoice_item("Testing", 10000, "invoice_1")
      end
      
      should "set up an invoice correctly" do
        skip 'set up an invoice correctly'
        @user.number_of_free_gigabytes = 10
        @user.expects(:unbilled_usage).returns(20.gigabytes)
        @user.expects(:create_invoice_item).with("10 GB free bandwidth", 0, "invoice_1")
        @user.expects(:create_invoice_item).with("10 GB paid bandwidth", 200, "invoice_1")
        @user.bill_unbilled_usage_to_invoice("invoice_1")
      end
      
      should "set up an invoice correctly with no usage" do
        skip 'set up an invoice correctly with no usage'
        @user.number_of_free_gigabytes = 10
        @user.expects(:unbilled_usage).returns(0.gigabytes)
        @user.expects(:create_invoice_item).with("10 GB free bandwidth", 0, "invoice_1")
        # @user.expects(:create_invoice_item).with("10 GB paid bandwidth", 600, "invoice_1")
        @user.bill_unbilled_usage_to_invoice("invoice_1")
      end
    end
  end

end
