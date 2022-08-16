class TempFile
  include Mongoid::Document
  include Mongoid::Timestamps

  field :dir, type: String
  field :full_path, type: String
  field :mark_for_clean, type: Boolean, default: false

  def self.mark_for_clean_by_full_path(full_path)
    file = TempFile.find_by(full_path: full_path)
    file.update_attribute(:mark_for_clean, true)
  end

  def self.clean_up
    files = TempFile.where(mark_for_clean: true, :updated_at.lte => Time.now-1.minute)
    files.each do |f|
      begin
        FileUtils.remove_entry_secure f.dir
      rescue

      end
      f.delete
    end
  end
end
