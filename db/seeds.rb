# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#, :roles => ["admin"]
User.create!({:email => "john@gmail.com", :password => "12345678", :password_confirmation => "12345678", :accepted_terms => true, :first_name=>"John", :last_name=>"Doe"})
Role::ROLES.each do |role|
  r = Role.new
  r.role = role;
  r.selected = true;
  User.first.roles << r
end

