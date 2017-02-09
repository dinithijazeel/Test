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
#
# Load profile
#
require File.expand_path("../../profiles/#{ENV['PROFILE']}.rb", __FILE__)
