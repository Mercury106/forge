module GithubApiMock
  include WebMock::API

  def self.enable(hook_id)
    stub_request(:post, 'https://api.github.com/repos/build/hooks')
      .with(body: /redeploy/,
            headers: { 'Accept' => /github/, 'Authorization' => /str/ })
      .to_return(status: 200,
                 headers: { 'Content-Type' => 'application/json' },
                 body: { id: hook_id,
                         name: 'web',
                         'events': [
                           'push'
                         ],
                         'active': true,
                         'config': {
                           'url': 'http://example.com/webhook',
                           'content_type': 'json'
                         },
                         'updated_at': Time.zone.now,
                         'created_at': Time.zone.now
                       }.to_json
                )
    stub_request(:delete, "https://api.github.com/repos/build/hooks/#{hook_id}")
      .with(body: '{}',
            headers: { 'Accept' => /github/, 'Authorization' => /str/ })
      .to_return(:status => 204, :body => "", :headers => {})
  end
end