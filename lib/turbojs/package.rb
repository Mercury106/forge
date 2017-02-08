module TurboJS
  module Models
    class Package
      attr_reader :uri, :slug, :options
      attr_accessor :pages, :redirects

      def initialize(uri, slug, options = {})
        @uri     = uri
        @slug    = slug
        @options = {
          max_depth: 20,
          user_agent: 'TurboJS Spider',
          ignore_exts: %w{png jpg jpeg gif}
        }.merge(options)
      end

      def spider!
        self.pages     = []
        self.redirects = []

        Spidr.site(uri, options) do |agent|
          agent.every_page do |page|
            agent.pause! if pages.length > 40
          end

          agent.every_ok_page do |page|
            yield page if block_given?
          end

          agent.every_html_page do |page|
            pages << page
          end

          agent.every_redirect_page do |page|
            redirects << page
          end
        end

        true
      end
      
      def from_zip(path)
      end

      def src
        ['/', App.settings.package_host, path] * '/'
      end

      def path
        "#{slug}.js"
      end

      def destroy!
        object = s3_bucket.objects.find(path)
        object && object.destroy
      rescue S3::Error::NoSuchKey
      end

      def upload!
        object = s3_bucket.objects.build(path)
        object.content          = GZip.compress(compile)
        object.content_type     = 'application/javascript'
        object.content_encoding = 'gzip'
        object.cache_control    = 'public,max-age=60'
        object.save
        object
      end

      def compile
        <<-EOF.dedent
          /* TurboJS v1.0 */;
          TurboJS.url   = #{uri.to_s.inspect};
          TurboJS.slug  = #{slug.inspect};
          TurboJS.cache = #{to_json};
          TurboJS.run();
        EOF
      end

      def self.to_json(value)
        case value
        when Hash
          value = value.map do |k,v|
            "#{k.to_s.inspect}: #{to_json(v)}"
          end
          '{' + value.join(',') + '}'
        when Array
          value = value.map {|v| to_json(v) }
          '[' + value.join(',') + ']'
        when String
          value.force_encoding('UTF-8')
          value.inspect
        else
          value.to_s
        end
      end

      def to_json(options = nil)
        self.class.to_json(as_json)
      end

      def as_json(options = nil)
        pages_hash.merge(redirect_hash)
      end

      protected

      def pages_hash
        pages.inject({}) do |hash, page|
          hash[page.url.path] = {html: page.body}
          hash
        end
      end

      def redirect_hash
        redirects.inject({}) do |hash, page|
          redirect_to = URI.parse(page.redirect_to).path
          hash[page.url.path] = {redirect: redirect_to}
          hash
        end
      end

      def s3
        @s3 ||= S3::Service.new(
          :access_key_id     => App.settings.aws_access_key,
          :secret_access_key => App.settings.aws_secret_key
        )
      end

      def s3_bucket
        s3.buckets.find(App.settings.package_bucket)
      end
    end
  end
end