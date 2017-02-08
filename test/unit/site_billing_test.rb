require 'test_helper'

class SiteBillingTest < ActiveSupport::TestCase
  context "A site" do
    setup do
      VCR.insert_cassette 'site-billing'
      @site = FactoryGirl.create(:site)
    end

    teardown do
      VCR.eject_cassette
    end
    
    context "with bandwidth added" do
      setup do
        assert @site.add_usage(10.megabytes, Time.now)
      end
      
      should "have bandwidth since its last billing date" do
        assert_equal @site.unbilled_usage, 10.megabytes
      end
      
      context "once billed" do
        setup do
          @site.mark_as_billed!
        end
        
        should "not have any bandwdith" do
          assert_equal 0, @site.unbilled_usage
        end
      end
    end
  end
end
