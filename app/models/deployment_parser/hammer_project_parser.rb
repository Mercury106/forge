# hammer build-in project parser
# to use this parser, hammer-gem with rails support should be added to gemfile
# gem 'jsx'
# gem 'hammer', git: 'https://github.com/RiotHQ/hammer-gem.git', branch: 'rails_support'

# require 'hammer/hammer'
# class DeploymentParser::HammerProjectParser < DeploymentParser
#   def parse
#     params = YAML.load_file(Rails.root.to_s + '/config/hammer.yml')
#     return unless @version
#     return unless params['whitelisted_emails'].include? @version.site.user.email
#     if File.exist?("#{@local_directory}/hammer.json")
#       ConsoleLogger.ok('[hammer compiler] hammer project detected')
#       version = File.read(Gem.loaded_specs['hammer'].full_gem_path + '/VERSION')
#       ConsoleLogger.ok("[hammer compiler] hammer version #{version.strip}")
#       # create one more tmp dir
#       input_directory = "/tmp/#{SecureRandom.hex}"
#       # move all files to new dir
#       FileUtils.mv(@local_directory, input_directory)
#       # compile project from new dir to old dir
#       tmp_dir = Dir.mktmpdir
#       opts = {
#         cache_directory: tmp_dir,
#         input_directory: input_directory,
#         output_directory: @local_directory,
#         optimized: false
#       }
#       build = Hammer::Build.new(opts)
#       ConsoleLogger.ok('[hammer compiler] building hammer project')
#       results_count = build.compile.count
#       ConsoleLogger.ok("[hammer compiler] hammer compiled #{results_count} files")
#       # clean up
#       FileUtils.rm_rf(input_directory)
#       FileUtils.rm_rf(tmp_dir)
#     end
#   end
# end