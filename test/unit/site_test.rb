require "test_helper"

class SiteTest < ActiveSupport::TestCase

  context "A site with an uppercase URL" do
    setup do
      @site = FactoryGirl.create(:paid_site, :url => "www.EXAMPL23fE.com")
      @site.save()
    end
    should "have a lowercase URL" do
      assert_equal "www.exampl23fe.com", @site.url
    end
  end

  context "When a site with www. exists" do
    setup do
      @site = FactoryGirl.create(:paid_site, :url => "www.example.com")
    end

    should "not allow a new site to be created without www" do
      site2 = FactoryGirl.build(:paid_site, :url => "example.com", :user => @site.user)
      assert !site2.valid?
    end
  end
  
  context "A site" do
    setup do
      @site = FactoryGirl.build(:site)
    end

    should "be valid" do
      assert @site.valid?
    end

    context "with an invalid name" do

      setup do
        @site.url = "www.getforge.io"
      end

      should "be invalid" do
        assert !@site.valid?
        assert_equal @site.errors[:url], ["is restricted"]
        assert !@site.save
      end
    end
  end
end
