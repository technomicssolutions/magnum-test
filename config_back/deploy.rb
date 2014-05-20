# config valid only for Capistrano 4.1
lock '3.1.0'
#require 'capistrano/ext/multistage'
#require 'capistrano_recipes'
set :application, 'espestco'
#set :repo_url, 'git@example.com:me/my_repo.git'
role :app, "example.com"
role :web, "example.com"

set :user, "root"
set :stages, ["staging", "production"]
set :default_stage, "production"

#set :branch, "master"
#set :scm, 'git'
#set :repo_url, "https://www.github.com/technomicssolutions/smartbook.git"
#set :rails_env, "production"
#set :deploy_to, "/var/www/"
#set :deploy_via, :copy
#set :repo_url, 'http://testuser:S3DLPdh4@github.12southmusic.com:/root/test-project.git'
#-------------------------------------------------------------------------------------------------------------------
set :scm, :git
#set :repo_url, 'https://github.com/technomicssolutions/smartbook.git'
set :repo_url, 'http://github.12southmusic.com:/root/test-project.git'
set :branch, 'master'
#set :git_http_username, 'technomics'
#set :git_http_password, 'tech123'
set :git_http_username, 'testuser'
set :git_http_password, 'testuser'
set :deploy_to, '/usr/local/test-project'
set :deploy_via, :copy
set :port, 8000
set :pty, true
set :log_level, :debug

#db_admin_user = root
#db_admin_pass = qwEsqCWZEY5SPvNd
#db_name = mysql
#-------------------------------------------------------------------------------------------------------------------
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

#-------------
namespace :deploy do

# desc 'Restart application'
#  task :restart do
#    on roles(:app), in: :sequence, wait: 5 do
#      # Your restart mechanism here, for example:
#      # execute :touch, release_path.join('tmp/restart.txt')
#    end
#  end
#
#  after :publishing, :restart
#
#  after :restart, :clear_cache do
#    on roles(:web), in: :groups, limit: 3, wait: 10 do
#      # Here we can do anything such as:
#      # within release_path do
#      #   execute :rake, 'cache:clear'
#      # end
#    end
#  end
# server 'example.com', roles: [:web, :app]
# desc "Report Uptimes"
# task :uptime do
#   on roles(:all) do |host|
#      execute :uptime
#      info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
#   end
# end

#--Task for Cheking th write Permission opf deploy_to directory ----------------------------
 desc "Check that we can access everything"
   task :check_write_permissions do
      on roles(:all) do |host|
        if test("[ -w #{fetch(:deploy_to)} ]")
          info "#{fetch(:deploy_to)} is writable on #{host}"
        else
          error "#{fetch(:deploy_to)} is not writable on #{host}"
        end
      end
 end
#------------------------------------------------------------------------------------------

#---Task to create MySQL DB and DB user----------------------------------------------------
  desc "Create database and database user"
  task :create_mysql_database do
    ask :db_root_password, ''
    ask :db_name, fetch(:application)
    ask :db_user, 'root'
    ask :db_pass, ''

    on primary fetch(:migration_role) do
      execute "mysql --user=root --password=#{fetch(:db_root_password)} -e \"CREATE DATABASE IF NOT EXISTS #{fetch(:db_name)}\""
      execute "mysql --user=root --password=#{fetch(:db_root_password)} -e \"GRANT ALL PRIVILEGES ON #{fetch(:db_name)}.* TO '#{fetch(:db_user)}'@'localhost' IDENTIFIED BY '#{fetch(:db_pass)}' WITH GRANT OPTION\""
    end
  end
#------------------------------------------------------------------------------------------
 desc "Check DB existance"
 task :check_mysql_db do
    exists = false

    run "mysql --user=#{db_admin_user} --password=#{db_admin_pass} --execute=\"show databases;\"" do |channel, stream, data|
      exists = exists || data.include?(db_name)
    end

    exists
  end
end
