module RequestHelpers
  def json
    @json ||= JSON.parse(response.body)
  end

  def sign_in_as(user)
    post_via_redirect(user_session_path,
                      {
                        'session[email]' => user.email,
                        'session[password]' => user.password
                      }
                     )
  end
end

module ActionDispatch::Integration::RequestHelpers
  def options(path, parameters = nil, headers_or_env = nil)
    process :options, path, parameters, headers_or_env
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
