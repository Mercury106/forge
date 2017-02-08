desc "Update all invoices"

namespace :forge do

  namespace :proxy do

    desc "Compile the proxy into proxy/proxy.js"
    task :compile => :environment do
      Dir.chdir(File.join(Rails.root, "proxy")) do
        puts "Compiling proxy/proxy.coffee to proxy/proxy.js"
        sh "coffee -c proxy.coffee"
        puts "Compiling proxy/deleter.coffee to proxy/deleter.js"
        sh "coffee -c deleter.coffee"
      end
    end

    desc "just upload"
    task :push => :compile do
      Dir.chdir(File.join(Rails.root, "proxy")) do
        sh "scp proxy.js asgard:~"
        sh "scp deleter.js asgard:~"
      end
    end

    desc "Upload the compiled proxy to Asgard"
    task :upload => :compile do
      puts "Done.\n\n - Backing up existing Asgard proxy script..."

      sh "ssh asgard 'mkdir -p backup'"

      sh "ssh asgard 'cp proxy.js backup/proxy-backup#{Time.now.to_i}.js'"

      puts "Done.\n\n - Backing up existing Asgard deleter script..."
      sh "ssh asgard 'cp deleter.js backup/deleter-backup#{Time.now.to_i}.js'"

      puts "Done.\n\n - Uploading to Asgard server..."
      Dir.chdir(File.join(Rails.root, "proxy")) do
        sh "scp proxy.js asgard:~"
        sh "scp deleter.js asgard:~"
      end

      puts "Done.\n\n - Restarting Asgard..."
      sh "ssh -t asgard 'sudo restart node'"
      sh "ssh -t asgard 'sudo restart deleter'"

      puts "Done.\n\n - Checking www.riothq.com:"
      sh "curl -Is www.riothq.com"
      puts "Done.\n\n - Checking riothq.com:"
      sh "curl -Is riothq.com |grep HTTP"
    end

    task :run => :compile do
      Dir.chdir(File.join(Rails.root, "proxy")) do
        puts "Running proxy/proxy.js..."
        sh "node proxy.js"
      end
    end

    task :test do
      puts "Testing riothq.com..."
      sh "curl -Is riothq.com/index.html |grep 200"
      sh "curl -Is riothq.com/ |grep 200"
      sh "curl -Is riothq.com/laksdjf |grep 404"
      sh "curl -Is riothq.com/404.html |grep 404"
    end

    task :test_local do
      puts "Testing node proxy. Ensure forge:proxy:run is running!"
      puts "Testing localhost:8080/index.html..."
      sh "curl -Is localhost:8080/index.html |grep 200"
      sh "curl -Is localhost:8080/ |grep 200"
      sh "curl -Is localhost:8080/laksdjf |grep 404"
      sh "curl -Is localhost:8080/404.html |grep 404"
    end
  end

  task :precompile => :environment do

    asset_pipeline_filename = File.join(Rails.root, 'app', 'assets', 'javascripts', 'turbojs', 'turbo.js')
    vendored_filename = File.join(Rails.root, "public", "assets", "turbojs", "turbo.js")
    FileUtils.rm asset_pipeline_filename if File.exist? asset_pipeline_filename

    Dir.chdir(Rails.root + "public/assets/turbojs") do
      FileUtils.rm "turbo.js" if File.exist? "turbo.js"
      FileUtils.rm "turbojs" if File.exist? "turbojs"
      sh "curl http://forge.dev/assets/turbojs/turbo.js > turbojs"
      sh "mv turbojs turbo.js"
    end

    FileUtils.cp vendored_filename, asset_pipeline_filename

  end
end