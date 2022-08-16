class Polar
  include Mongoid::Document
  include Mongoid::Timestamps

  after_save :after_save
  before_destroy :before_destroy
  after_destroy :after_destroy

  embedded_in :user

  field :name, type: String
  field :s3_path, type: String
  field :device_tokens, type: Array

  validates :name, presence: true

  #
  def name
    if self[:name].blank?
      return "polar"
    else
      return self[:name]
    end
  end

  def upload_file_to_s3(io, file_name)
    if (io.nil? || io.size == 0)
      self.errors.add(:base, "File is zero byte. Please select an other!")
      return
    elsif (io.size > 1.megabytes)
      self.errors.add(:base, "File is too large. This exceeds Polar file size limit of 1 MB")
      return
    end

    #validate content
    if (io.original_filename.match(".csv"))   #io.content_type == "text/csv" &&
      lines = io.tempfile.readlines
      io.tempfile.rewind
      is_comma = lines[0].match(",") != nil
      is_semmicolon= lines[0].match(";") != nil

      delimiter = is_comma ? "," : ";"
      first_line_split = lines[0].split(delimiter)
      has_angle = first_line_split[0] == "angle"
      all_line_has_same_collumn = true
      lines.each do |l|
        if l.split(delimiter).size != first_line_split.size
          all_line_has_same_collumn = false
        end
      end
      self.errors.add(:base, "Column delimiter is not valid!") if !is_comma && !is_semmicolon
      self.errors.add(:base, "File structure is not valid!") if !has_angle
      self.errors.add(:base, "File structure is not valid! Different column numbers!") if !all_line_has_same_collumn
      self.errors.add(:base, "Too many angles") if lines.size > 361
    else
      self.errors.add(:base, "File is not a valid polar file!")
      return
    end

    begin
      token =SecureRandom.urlsafe_base64(nil, false)
      x = s3.put_object({acl: "private",
                         bucket: "seamantec-cloud-#{Rails.env}",
                         server_side_encryption: "AES256",
                         key: "#{self.user.id.to_s}/#{token}-#{file_name}",
                         body: io,
                         content_type: "text/csv"
                        })
      self.s3_path = "#{self.user.id.to_s}/#{token}-#{file_name}"
    rescue Exception => e
      self.errors.add(:base, "File not uploaded")
    end
  end

  def update_file(io)
    if (io.nil? || io.size == 0)
      self.errors.add(:base, "File is zero byte. Please select an other!")
      return
    elsif (io.size > 1.megabytes)
      self.errors.add(:base, "File is too large. This exceeds Polar file size limit of 1 MB")
      return
    end
    begin
      x = s3.put_object({acl: "private",
                         bucket: "seamantec-cloud-#{Rails.env}",
                         server_side_encryption: "AES256",
                         key: s3_path,
                         body: io,
                         content_type: "text/csv"
                        })
    rescue Exception => e
      self.errors.add(:base, "File not uploaded")
    end
  end

  def download_file_from_s3
    temp_dir = Dir.mktmpdir
    save_path = temp_dir +"/o_#{self.name}.csv"
    TempFile.create(dir: temp_dir, full_path: save_path)
    file = File.open(save_path, "wb")
    if self.s3_path.present?
      resp = s3.get_object({bucket: "seamantec-cloud-#{Rails.env}",
                            key: self.s3_path}, target: file)
    end
    if file.size == 0
      return nil
    end

    return file
  end

  def send_to_devices
    remove_other_polar_devices
    self.device_tokens = self.user.devices.map { |d| d.token }
    self.save
    WebsocketRails[self.user.id.to_s].trigger 'new_polar', {polar_id: self.id.to_s}
  end

  def remove_other_polar_devices
    self.user.polars.each do |polar|
      polar.update_attribute(:device_tokens, nil)
    end
  end

  def as_json(options = nil)
    res = super(options)
    res["id"] = res.delete("_id").to_s
    res
  end


  private
  def s3
    Aws::S3::Client.new(
        region: "us-east-1",
        credentials: Aws::Credentials.new(CONFIGS[:s3]["user"], CONFIGS[:s3]["access_key"])
    )

  end

  private
  def after_save
    Fiber.new do
      WebsocketRails[self.user.id.to_s].trigger 'new_polar', {polar_id: self.id.to_s}
    end.resume
  end

  def before_destroy
    @user_id = self.user.id.to_s
    @file_path = self.s3_path
  end

  def after_destroy
    WebsocketRails[@user_id].trigger 'deleted_polar', {}
    begin
      s3.delete_object({bucket: "seamantec-cloud-#{Rails.env}",
                        key: @file_path})
    rescue Exception => e
      puts e
    end

  end


end
