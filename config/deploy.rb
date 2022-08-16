set :application, 'Seamantec.com'
set :repo_url, 'git@bitbucket.org:seamantec/harbor.git'

set :branch, -> { fetch(:git_branch) }

set :deploy_to, -> { fetch(:deploy_directory) }
set :scm, :git

current_stage = fetch(:stage)

# set :format, :pretty
# set :log_level, :debug
# set :pty, true
set :pty, false

set :linked_files, %w{config/mongoid.yml config/harbor.yml config/version.yml config/paypal.yml config/newrelic.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/resque public/.well-known}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5
set :resque_log_file, "log/resque.log"
# set :workers, { "invoice_generator" => 1, "license_email"=>2, "utils"=>1 }


namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  task :symlink_config_files do
    # on roles(:app) do
    #   execute "ln -sf #{shared_path  }/config/mongoid.yml  #{ current_path }/config/mongoid.yml"
    #   execute "ln -sf #{shared_path  }/config/harbor.yml  #{ current_path }/config/harbor.yml"
    #   execute "ln -sf #{shared_path  }/config/version.yml  #{ current_path }/config/version.yml"
    #   execute "ln -sf #{shared_path  }/config/paypal.yml  #{ current_path }/config/paypal.yml"
    #   execute "ln -sf #{shared_path  }/config/newrelic.yml  #{ current_path }/config/newrelic.yml"
    #   execute "ln -sf #{shared_path  }/bin  #{ current_path }/bin"
    #   execute "ln -sf #{shared_path  }/log  #{ current_path }/log"
    #   execute "ln -sf #{shared_path  }/tmp/pids  #{ current_path }/tmp/pids"
    #   execute "ln -sf #{shared_path  }/tmp/cache  #{ current_path }/tmp/cache"
    #   execute "ln -sf #{shared_path  }/tmp/sockets  #{ current_path }/tmp/sockets"
    #   execute "ln -sf #{shared_path  }/vendor/bundle  #{ current_path }/vendor/bundle"
    #   execute "ln -sf #{shared_path  }/public/system  #{ current_path }/public/system"
    #   execute "ln -sf #{shared_path  }/public/resque  #{ current_path }/public/resque"
    # #   execute "ln -sf #{ deploy_to }/shared/config/mongoid.yml #{ current_path }/config/mongoid.yml"
    # #   execute "ln -sf #{ deploy_to }/shared/config/harbor.yml #{ current_path }/config/harbor.yml"
    # #   execute "ln -sf #{ deploy_to }/shared/config/version.yml #{ current_path }/config/version.yml"
    # end
  end
  after :restart, :clear_cache do
    on roles(:app), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        execute :rake, 'websocket_rails:stop_server'
        execute :rake, "websocket_rails:start_server RAILS_ENV=#{current_stage}"
      end
    end
  end


  task :start_websocket do
    on roles(:app) do
      within release_path do
        execute :rake, "websocket_rails:start_server RAILS_ENV=#{current_stage}"
      end
    end
  end
  task :stop_websocket do
    on roles(:app) do
      within release_path do
        execute :rake, "websocket_rails:stop_server RAILS_ENV=#{current_stage}"
      end
    end
  end


  after :finishing, 'deploy:cleanup'

end


# task :fake_harbor_yml do
#   on roles(:app) do
#     execute "cp #{release_path}/config/harbor.yml.sample #{release_path}/config/harbor.yml"
#   end
# end
namespace :bootstrap do
  task :upload_harbor_yml do
    on roles(:app) do
      upload!("config/harbor.yml.#{current_stage}", "#{shared_path  }/config/harbor.yml")
    end
  end
  task :upload_configs do
    Rake::Task["bootstrap:upload_harbor_yml"].invoke
    on roles(:app) do
      upload!("config/mongoid.yml.#{current_stage}", "#{shared_path  }/config/mongoid.yml")
      upload!("config/newrelic.yml", "#{shared_path  }/config/newrelic.yml")
      upload!("config/paypal.yml.#{current_stage}", "#{shared_path  }/config/paypal.yml")
    end
  end

  task :upload_version_yml do
    on roles(:app) do
      upload!("config/version.yml", "#{shared_path}/config/version.yml")
    end
  end
end


# before "deploy:assets:precompile", "fake_harbor_yml"
# after "deploy", "common:create_version_yml"
after "deploy", "bootstrap:upload_version_yml"
after "deploy", "bootstrap:upload_configs"
before "deploy", "bootstrap:upload_configs"
after "deploy", "deploy:symlink_config_files"
after "deploy", "deploy:restart"
after "deploy", "deploy:cleanup"
after "deploy:restart", "resque:restart"
after "deploy:restart", "resque:scheduler:restart"
