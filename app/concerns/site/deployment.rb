# Site::Deployment is concerned with deploying sites to the S3 bucket.
# We currently use a set of VersionUploader and VersionDeployer models for this
# If we can consolidate all calls to those objects into this module we can 
# hopefully keep deployment stuff compartmentalised into this module.
# That'd be nice. Separation of concerns and all that.

class Site < ActiveRecord::Base
  module Site::Deployment
    
    extend ActiveSupport::Concern
    
    included do
      attr_accessor :force_deploy
      attr_accessible :force_deploy
      
      # This will trigger a deployment (after save) if self.needs_deploy() returns true before save.
      before_save :set_force_deploy_if_needs_deploy, unless: 'Rails.env.test?'

      if Rails.env.test?
        after_save :deploy_if_forced
      else
        after_commit :deploy_if_forced
      end
      
      # When we change URLs, we have to remove the old directory from the S3 bucket.
      after_save :delete_old_deployment_if_url_has_changed
      
      # When we destroy, let's delete that directory completely.
      after_destroy :delete_from_s3_completely
    end
    
    def delete_from_s3_completely
      VersionUploader.new(:url => self.url).destroy_site()
    end

    def version_deployer
      VersionDeployer.new(:version => self.current_version, :url => self.url)
    end
    
    # Deploy is used to trigger a QC job. 
    # deploy_by_id is the class method we want.
    def deploy_from_right_source
      if dropbox_path.present?
        ImportFromDropboxWorker.perform_async(current_version_id)
      elsif github_path.present?
        ImportFromGithubWorker.perform_async(current_version_id)
      elsif current_version.upload.present?
        deploy
      else
        WebhookTriggerWorker.perform_async('deploy_failure', id)
        raise 'Current site version has no source for deploy'
      end
    end

    def deploy
      if Rails.env.test?
        deploy_without_delay()
      else
        self.current_version.update_column('percent_deployed', 0) rescue nil
        SiteDeployWorker.perform_async(self.id)
      end
    end

    def deploy_without_delay
      versions.where('id != ?', current_version_id).update_all(
        state: nil,
        percent_deployed: 100
      )
      current_version.update_attributes(state: nil, percent_deployed: 1)
      VersionDeployer.new(
        version: current_version, url: url
      ).deploy
    end

    module ClassMethods
      def deploy_by_id(id)
        Site.find(id).deploy_without_delay()
      end
    end
    
    def delete_old_deployment_if_url_has_changed
      if url_changed? && url_was
        VersionUploader.new(:url => url_was).destroy_site
      end
    end
    
    def needs_deploy
      persisted? && (current_version_id_changed? || url_changed? || squish_changed?)
    end
    
    # To "Force" a deploy means to make a deployment happen after save.
    # In the UI, force_deploy is used to re-deploy a site.
    
    def set_force_deploy_if_needs_deploy
      if needs_deploy
        self.force_deploy = true
      end
    end

    def deploy_if_forced
      if self.force_deploy
        self.force_deploy = false
        # deploy() TODO do we actually need this?
      end
    end
    
  end
end