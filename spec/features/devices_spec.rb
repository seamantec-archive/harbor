feature "list devices" do
  scenario "admin list user devices"
  scenario "user list own devices"
  scenario "user try list other user devices"
  scenario "list with unknown user"
end

feature "delete device" do
  scenario "admin can delete user device"
  scenario "user can delete own device"
  scenario "user try can delete other user device"
  scenario "delete with unknown user"
end

