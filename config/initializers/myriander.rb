#
## User roles
#
Rails.application.config.x.users.roles = {
  :root     => -1,
  :admin    => 1,
  :manager  => 5,
  :sales    => 10,
  :partner  => 15,
  :customer => 20,
}
Rails.application.config.x.staging = ENV['APP_STAGING'];
Rails.application.config.x.default_user_id = ENV['DEFAULT_USER_ID'];
#
# Load profile
#
require File.expand_path("../../profiles/#{ENV['PROFILE']}/#{ENV['PROFILE']}.rb", __FILE__)
