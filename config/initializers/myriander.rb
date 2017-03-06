#
# Load profile
#

puts "5555555555555555555555555555555555555555555555555555"
puts Rails.root.join('config/profiles', "#{ENV['TENANT']}/#{ENV['TENANT']}.yml").to_s
puts "5555555555555555555555555555555555555555555555555555"
Conf.add_source!(Rails.root.join('config/profiles', "#{ENV['TENANT']}/#{ENV['TENANT']}.yml").to_s)
Conf.reload!
