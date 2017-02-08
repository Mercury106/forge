class Site < ActiveRecord::Base
  include Site::Sockets unless Rails.env.test?
  include Deployment
  include Bandwidth
  include Domains
  include Usage
  include Dns
  include Favicon

  # Callbacks
  before_create :set_squish
  after_save :ensure_site_user
  after_commit :generate_first_version, unless: 'Rails.env.test?', on: :create

  # Scopes
  default_scope { order('url asc') }

  attr_accessible :url, :squish, :current_version_id, :users, :site_users,
                  :site_users_attributes, :user_attributes, :user_id,
                  :updated_at, :dropbox_path, :github_path, :github_branch,
                  :current_deploy_slug, :deploy_token, :dropbox_autodeploy,
                  :dropbox_cursor, :github_autodeploy, :github_webhook_id,
                  :hammer_enabled

  attr_accessor :deploy_token, :current_deploy_slug

  # VALIDATIONS
  validates_uniqueness_of :url
  # validates_format_of :url, :with => /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix, :message => "isn't valid.", multiline: true
  validate :check_www_version_does_not_exist_already
  validate :check_url_for_paid_users
  validate :restricted_domains

  # Associations
  belongs_to                    :user
  accepts_nested_attributes_for :user

  has_many                      :site_users
  accepts_nested_attributes_for :site_users

  has_many                      :users, :through => :site_users
  accepts_nested_attributes_for :users

  belongs_to :current_version, class_name: Version
  belongs_to :previous_version, class_name: Version
  has_many :versions, :dependent => :destroy

  has_many :webhook_triggers, dependent: :destroy
  has_many :forms, dependent: :destroy

  def ensure_site_user
    self.site_users.find_or_create_by(user_id: self.user_id)
  end

  def generate_first_version
    if versions.count == 0
      new_version = self.versions.create(description: 'Forge Sample Project')
      new_version.upload = File.open(File.join(Rails.root, 'fixtures', 'Forge Sample Project.zip'))
      new_version.save()
      new_version.percent_deployed = 0
      self.current_version = new_version
      save()
      # TODO: Test whether we need this.
      deploy()
    end
  end

    # Defaults
  def set_squish
    self.squish = true
  end

  def destroy
    # destroy even active version, look at models/version.rb:38
    self.current_version_id = nil
    super
  end

  def redeploy!(same_version = false, delay = 0)
    if !same_version
      version = versions.create
      old_version = current_version
      # version change
      update_columns(current_version_id: version.id,
                     previous_version_id: old_version.try(:id))
      if dropbox_path.present?
        ImportFromDropboxWorker.perform_async(version.id)
        return
      elsif github_path.present?
        ImportFromGithubWorker.perform_async(version.id)
        return
      else
        if Rails.env.production?
          upload = old_version.upload.url
        else
          upload = old_version.upload.path
        end

        version.upload = open(upload) if upload
        version.save
      end
    end
    # remove existing scheduled job
    existing_job = Sidekiq::ScheduledSet.new.find do |x|
      next if x.args.empty?
      x.args.first == [SiteDeployWorker, :perform_async, [id, true]].to_yaml
    end
    existing_job.delete if existing_job
    # re-run online hammer compilation if enabled
    current_version.update_columns(hammer_archive_url: nil) if hammer_enabled
    # deploy with delay
    SiteDeployWorker.perform_in(delay.to_i.seconds, reload.id, true)
  end

  def to_s
    url
  end

  def sync_method
    return 'Github' if github_path.present?
    dropbox_path.present? ? 'Dropbox' : 'File'
  end

  def self.fetch_by_url url
    normalized_url = url.gsub(/^www\./, '')
    find_by_url(normalized_url) || find_by_url("www.#{normalized_url}")
  end

  private

  # Validations
  def check_www_version_does_not_exist_already
    www_url = "www.#{self.url}"
    if Site.find_by_url(www_url)
      self.errors.add :url, "has already been used - Forge uses www. and non-www. URLs interchangeably."
    end
  end

  def check_url_for_paid_users
    if !url.ends_with? ".getforge.io"
      if !user.subscription_active
        self.errors.add :url, "can only be used with a Forge subscription."
      end
    end
  end

  def restricted_domains
    subdomains_we_do_not_allow = ['www', 'static', 'cdn', 'cache', 'admin', 'config']
    subdomains_we_do_not_allow.each do |subdomain|
      domain = "#{subdomain}.#{ENV['EXTERNAL_CNAME']}"
      if self.url == domain
        errors.add(:url, "is restricted")
        break
      end
    end
  end
end
