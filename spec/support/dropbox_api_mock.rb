module DropboxApiMock
  include WebMock::API
  def self.enable(cursor = nil)
    stub_request(:post, 'https://api.dropbox.com/1/delta')
      .with(
        body: { 'path_prefix' => /with_updated_files/ },
        headers: { 'User-Agent' => /OfficialDropboxRubySDK/ }
      ).to_return(
        :status => 200,
        :headers => {}, 
        :body => { 
                   'entries' => [ 
                     ['/index.html', 
                       {'rev' => '7744a05249d49',
                        'thumb_exists' => false,
                        'path' => '/Projects/site/index.html',
                        'is_dir' => false,
                        'client_mtime' => 'Tue, 10 Jul 2012 17:26:22 +0000',
                        'icon' => 'page_white_gear',
                        'read_only' => false,
                        'modifier' => nil,
                        'bytes' => 134656,
                        'modified' => 'Fri, 17 Aug 2012 16:59:59 +0000',
                        'size' => '13.5 KB',
                        'root' => 'dropbox',
                        'mime_type' => 'atext/html',
                        'revision' => 488522} ],
                     ['/about.html', 'metadata'],
                     ['/bad.html', nil]
                   ],
                   'reset' => !!cursor,
                   'has_more' => false,
                   'cursor' => 'with_updated_files'
                 }.to_json
      )

    stub_request(:post, 'https://api.dropbox.com/1/delta')
      .with(
        body: { path_prefix: '/without_updated_files' },
        headers: { 'User-Agent' => /OfficialDropboxRubySDK/ }
      ).to_return(
        :status => 200,
        :headers => {}, 
        :body => { 
                    'entries' => [],
                    'reset' => !!cursor,
                    'has_more' => false,
                    'cursor' => 'without_updated_files'
                  }.to_json
      )

    stub_request(:post, 'https://api.dropbox.com/1/delta')
      .with(
        body: { path_prefix: '/with_deleted_files' },
        headers: { 'User-Agent' => /OfficialDropboxRubySDK/ }
      ).to_return(
        :status => 200,
        :headers => {}, 
        :body => { 
                   'entries' => [['/bad.html', nil]],
                   'reset' => !!cursor,
                   'has_more' => false,
                   'cursor' => 'with_deleted_files'
                 }.to_json
      )
  end
end