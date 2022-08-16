class SetConfirmedAtForAllNonAnonymUser < Mongoid::Migration
  def self.up
    User.where(is_anonym: false).each do |u|
      u.update_attribute(:confirmed_at, Time.now)
    end
  end

  def self.down
    User.where(is_anonym: false).each do |u|
      u.update_attribute(:confirmed_at, nil)
    end
  end
end