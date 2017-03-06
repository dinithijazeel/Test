#
# Load profile
#
Conf.add_source!(Rails.root.join('config/profiles', "#{ENV['TENANT']}/#{ENV['TENANT']}.yml").to_s)
Conf.reload!
