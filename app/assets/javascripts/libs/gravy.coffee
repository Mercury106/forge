window.Gravy =
  "HTTP_URL": "http://www.gravatar.com/avatar/"
  
  "HTTPS_URL": "https://secure.gravatar.com/avatar/"
  
  valid: (email) ->
    
    /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i.test email
  
  to: (email, size, https) ->
    # MD5 (Message-Digest Algorithm) by WebToolkit
    # You must include the function to use it
    gravatar_id = MD5 email

    size ||= 64
    
    size = if size then "?s=#{size}" else ""
    
    url = if https then @HTTPS_URL else @HTTP_URL
    
    url + gravatar_id + size
  
  to_secure: (email, size) ->
    @to email, size, true
  
  img: (email, size) ->
    url = @to email, size
    
    "<img src='#{url}' />"
  
  img_secure: (email, size) ->
    url = @to email, size, true
    
    "<img src='#{url}' />"