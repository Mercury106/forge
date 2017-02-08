knox   = require('knox')
config = require('./config').config()
http   = require('http')
rimraf = require('rimraf')
file_path = require('path')
fs = require('fs')
spawn = require('child_process').spawn

filename404 = file_path.resolve(__dirname, '404.html')
error404    = fs.readFileSync(filename404)

s3 = knox.createClient {
  key:    config.key,
  secret: config.secret,
  bucket: "asgard-production",
}

server = http.createServer (req, res) ->
  address = req.headers.host.split(":")[0]
  
  # if (address.slice(0, 4) == "www.")
  #   address = address.slice(4)
  
  if (address == "getforge.io")
    res.writeHead 302,
      'Location': 'http://getforge.com'
    res.end()
  
  filename = req.url
  
  if(filename == '/_asgard_health_check.html')
    res.end()
  
  if(filename == "/_asgard_cache_buster")
    rimraf "/tmp/cache/#{address}", -> res.end()
    spawn('restart nginx', [], { stdio: 'inherit' })
    res.end()
    
  if !filename || filename == "/"
    filename = "/index.html"
  else if filename.slice(-1) == "/"
    filename += "index.html"
  else if filename[-5..-1] != ".html" && filename[-4..-1] != '.ico'
    filename += ".html"
  
  path = address + filename
  
  s3.get(path)
    .on('response', (res_from_s3) ->
      
      if(200 != res_from_s3.statusCode)
        res.writeHead(404, {'Content-Type': 'text/html'})
        res.write(error404)
        res.end()

      res.writeHead res_from_s3.statusCode, 'content-type': res_from_s3.headers['content-type']
      res_from_s3.on 'data', (chunk) -> res.write(chunk)
      res_from_s3.on 'end', -> res.end()
    ).end()

server.listen(config.port)