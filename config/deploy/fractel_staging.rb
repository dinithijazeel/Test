set :profile, 'fractel'
# set :branch, 'develop'
set :branch, 'release/1.2.4'
set :stage, :staging

set :rails_env, :production

# The domain for the application
set :server_name, 'dev-my.fractel.com'

# The canonical description
set :full_app_name, "#{fetch(:profile)}_#{fetch(:application)}_#{fetch(:stage)}"

# Deployment server and path
server 'sumac.fractel.net', port: 32937, user: fetch(:deploy_user), roles: %w{web app db}, primary: true
set :deploy_to, "/home/#{fetch(:deploy_user)}/Code/#{fetch(:full_app_name)}"

# Number of unicorn workers, used for
# unicorn.rb and other configs
set :unicorn_worker_count, 2

set :enable_ssl, true
set :ssl_certificate, 'fractel.com'
