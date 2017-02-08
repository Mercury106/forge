require 'test_helper'

class VersionTest < ActiveSupport::TestCase

  context "A version" do
    setup do
      # TODO: Skipping domain checking should definitely be handled somewhere else.
      @version = FactoryGirl.build(:version)
    end
    
    should "be valid" do
      assert @version.valid?
      assert @version.site.valid?
    end
    
    context "when generating a hash" do
      setup do
        @version.file_hash = {'index.html' => '123', 'about.html' => '234', 'contact.html' => '345'}
        @previous_version = FactoryGirl.build(:version, :file_hash => {'index.html' => '234', 'about.html' => '234', 'deleted.html' => '456'})
        @version.expects(:previous_version).returns(@previous_version)
      end
      
      should "set the right diff for the files that have changed" do
        @version.set_diff
        assert_equal @version.diff, {:modified => ['index.html'], :added => ['contact.html'], :deleted => ['deleted.html']}
      end
    end
  end

end
