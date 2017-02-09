set :application, 'myriander'
set :deploy_user, 'deploy'

set :repo_url, 'git@github.com:fractel/myriander.git'

# rbenv
set :rbenv_type, :system
set :rbenv_ruby, '2.2.6'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# Old release buffer
set :keep_releases, 5

# Shared configuration
set :linked_files, %w{.env config/database.yml config/secrets.yml config/unicorn.rb}

# Shared directories
set :linked_dirs, %w{bin log uploads tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/docs}

# Required tests
set :tests, []

# Ask for sudo password
set :pty, true

# Default .env additions
set :default_env, {}

# Config files to copy on deploy:setup
set(:config_files, %w(
  .env.example
  database.yml
  log_rotation
  nginx.conf
  resque.service
  unicorn.rb
  unicorn.service
  secrets.yml
))

# Config files to make executable
set(:executable_config_files, [])

# Additional symlinks for deploy:setup_config
set(:symlinks, [
  {
    source: 'nginx.conf',
    link: '/etc/nginx/sites-enabled/{{full_app_name}}'
  },
  {
    source: 'log_rotation',
    link: '/etc/logrotate.d/{{full_app_name}}'
  },
])

# http://www.capistranorb.com/documentation/getting-started/flow/

namespace :deploy do
  # Make sure we're deploying what we think we're deploying
  before :deploy, 'deploy:check_revision'
  # Only allow a deploy with passing tests to deployed
  before :deploy, 'deploy:run_tests'
  # Compile assets locally, then rsync
  after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  after :finishing, 'deploy:cleanup'

  # Remove the default nginx configuration
  # to prevent conflicts
  before 'deploy:setup_config', 'nginx:remove_default_vhost'

  # Reload nginx to pick up new/modified vhosts
  after 'deploy:setup_config', 'nginx:reload'

  # Restart application
  after 'deploy:publishing', 'deploy:restart'
end
