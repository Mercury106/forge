desc "Update all invoices"

namespace :versions do
  task reset_deployments: :environment do
    Version.update_all :percent_deployed => 100
  end

  task fix_encoding: :environment do
    puts "Fix filenames encoding..."
    Version.skip_callback(:save, :after, :send_push_for_percent_deployed)
    class Version
      module Diff
        def file_hash=(new_file_hash)
          write_attribute(:file_hash, new_file_hash)
        end
      end
    end
    Version.find_each(batch_size: 100) do |v|
      new_file_hash = {}
      new_diff = {}

      v.file_hash.each do |key, val|
        new_file_hash[key.encode_utf8] = val
      end if v.file_hash.respond_to?(:each)

      v.diff.each do |key, val|
        new_diff[key] = val.map{ |x| x.encode_utf8 }
      end if v.diff.respond_to?(:each)

      if new_file_hash != {} || new_diff != {}
        v.file_hash = new_file_hash
        v.diff = new_diff
        v.save
      end
    end

  end
end