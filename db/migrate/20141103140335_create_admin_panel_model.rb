class CreateAdminPanelModel < Mongoid::Migration
  def self.up
    AdminPanel.create()
  end

  def self.down
    AdminPanel.first.delete
  end
end