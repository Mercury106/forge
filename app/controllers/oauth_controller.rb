class OauthController < ApplicationController

  def github
    code = params[:code]

    client_id = "239591d9f61160fb04c3"
    client_secret = "c96a74644f0ef83204cff72a6eab221bb694cca4"
    url = "https://github.com/login/oauth/access_token"
    uri = URI.parse(url)

    res = Net::HTTP.post_form(uri, 'client_id' => client_id, 'client_secret' => client_secret, 'code' => code)
    @token = params_from(res.body)['access_token']
 
    render :layout => false
  end

  def dropbox
    render :layout => false
  end

private

  def params_from(query_string)
    qs = {}
    query_string.split(/[&]/).each do | kv |
      # now split on the = and set k and v (short for key, value)
      k, v = kv.split(/[=]/)
      # fill the qs array
      qs[k] = v
    end
    qs
  end

end
