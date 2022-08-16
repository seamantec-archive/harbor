set :stages, %w(production beta)
set :default_stage, "beta"
require 'capistrano/ext/multistage'


set :scm, :git


set :branch, "develop"
set :user, "ubuntu"
set :rvm_ruby_string, "ruby-2.0.0-p353"
set :rvm_type, :default
set :ssh_options, {:forward_agent => true}
set :bundle_dir, ''
set :bundle_flags, '--system --quiet'

set :use_sudo, false
set :deploy_to, "/home/ubuntu/webapp"
set :rails_env, "beta"
set :deploy_via, :remote_cache
set :deploy_subdir, "webapp"
set :normalize_asset_timestamps, false

role :web, "seamantec_com" # Your HTTP server, Apache/etc
role :app, "seamantec_com" # Your HTTP server, Apache/etc
role :db, "seamantec_com",:primary => true # Your HTTP server, Apache/etc
set :keep_releases, 5

#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do

  end
  task :stop do

  end
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  task :symlink_config_files do
    run "#{ try_sudo } ln -sf #{ deploy_to }/shared/config/mongoid.yml #{ current_path }/config/mongoid.yml"
    run "#{ try_sudo } ln -sf #{ deploy_to }/shared/config/harbor.yml #{ current_path }/config/harbor.yml"
    run "#{ try_sudo } ln -sf #{ deploy_to }/shared/config/version.yml #{ current_path }/config/version.yml"
  end
end

namespace :bootstrap do
  task :upload_configs do
    upload_webapp_yml
    upload("config/mongoid.yml.prod", "/home/ubuntu/webapp/shared/config/mongoid.yml")
  end
  task :upload_harbor_yml do
    upload("config/harbor.yml.beta", "/home/ubuntu/webapp/shared/config/harbor.yml")
  end
  task :upload_version_yml do
    upload("config/version.yml", "/home/ubuntu/webapp/shared/config/version.yml")
  end
end

namespace :common do
  task :create_version_yml do
    new_full = ""
    File.open("config/version.yml", 'r') do |f|
        i = 0
        f.each_line do |line|
          if i == 0
            first_line = line
            old_version = first_line.slice(first_line.index(" "), first_line.length).gsub(/\s/, "")
            puts "|#{old_version}|"
            new_version_end = old_version.split(".")[3].to_i # + 1
            new_full = old_version.split(".")[0..2].join(".") + ".#{new_version_end}"
            puts "version: #{new_full}"

          end
          i += 1

        end
        f.close()
    end
    commit_version = `git rev-parse HEAD`
    version_yml = File.open("config/version.yml", 'w+')
    version_yml.puts "version: #{new_full}"
    version_yml.puts "commit_version: #{commit_version}"
    version_yml.puts "build_date: #{Time.now}"
    version_yml.close()

  end

end

task :fake_harbor_yml do
  run "cp #{release_path}/config/harbor.yml.sample #{release_path}/config/harbor.yml"
end

before "deploy:assets:precompile", "fake_webapp_yml"
after "deploy", "common:create_version_yml"
after "deploy", "bootstrap:upload_version_yml"
after "deploy", "deploy:symlink_config_files"
after "deploy", "deploy:restart"
after "deploy", "deploy:cleanup"
