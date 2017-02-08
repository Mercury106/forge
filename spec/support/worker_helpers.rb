module WorkerHelpers
  include WebMock::API
  class FakeDropboxClient

    def initialize(token)
      @token = token
    end

    def delta(cursor, path)
      stub_request(:post, 'api.dropbox.com').
      with(
        body: {
              '/with_updated_files' =>
                { 
                  'entries' => [ 
                    ['/index.html', 
                      {"rev"=>"7744a05249d49",
                       "thumb_exists"=>false,
                       "path"=>"/Projects/site/index.html",
                       "is_dir"=>false,
                       "client_mtime"=>"Tue, 10 Jul 2012 17:26:22 +0000",
                       "icon"=>"page_white_gear",
                       "read_only"=>false,
                       "modifier"=>nil,
                       "bytes"=>134656,
                       "modified"=>"Fri, 17 Aug 2012 16:59:59 +0000",
                       "size"=>"13.5 KB",
                       "root"=>"dropbox",
                       "mime_type"=>"atext/html",
                       "revision"=>488522} ],
                    ['/about.html', 'metadata'],
                    ['/bad.html', nil]
                  ],
                  'reset' => !!cursor,
                  'has_more' => false,
                  'cursor' => 'with_updated_files'
                },
              '/without_updated_files'  =>
                { 
                  'entries' => [],
                  'reset' => !!cursor,
                  'has_more' => false,
                  'cursor' => 'without_updated_files'
                },
              '/with_deleted_files'  =>
                { 
                  'entries' => [['/bad.html', nil]],
                  'reset' => !!cursor,
                  'has_more' => false,
                  'cursor' => 'wit_deleted_files'
                }
              }[path || '/with_updated_files']
            )
    end
  end
end

RSpec.configure do |config|
  config.include WorkerHelpers, type: :worker
end