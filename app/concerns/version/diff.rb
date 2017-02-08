class Version < ActiveRecord::Base
  module Diff

    extend ActiveSupport::Concern
    
    def previous_version
      self.site.versions.where("id < ?", self.id).order('id DESC').limit(1).first
    end
    
    included do
      serialize :file_hash
      serialize :diff
      attr_accessible :diff
    end
    
    def set_diff
      diff_hash = {}
      
      self.file_hash ||= {}

      previous_file_hash = previous_version.try(:file_hash) || {}
      self.file_hash.keys.each do |key|
        next if key.include? ".git/"
        if previous_file_hash[key] == nil
          diff_hash[:added] ||= []
          diff_hash[:added] << key
        elsif previous_file_hash[key] != self.file_hash[key]
          diff_hash[:modified] ||= []
          diff_hash[:modified] << key
        end
      end
      
      previous_file_hash.keys.each do |key|
        if !self.file_hash[key]
          next if key.include? ".git/"
          diff_hash[:deleted] ||= []
          diff_hash[:deleted] << key
        end
      end

      self.diff = diff_hash
    end

    def file_hash=(new_file_hash)
      write_attribute(:file_hash, new_file_hash)
      self.set_diff()
    end
    
  end
end