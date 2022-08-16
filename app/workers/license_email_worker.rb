class LicenseEmailWorker
  @queue = :license_email

  def self.perform(license_ids)
    #
    licenses = []
    license_ids.each do |id|
      licenses << License.find(id)
    end
    begin
      UserMailer.welcome_email_with_serial(licenses).deliver
      licenses.each do |lic|
        lic.set_email_sent
      end
    rescue Exception => e
      licenses.each do |lic|
        lic.set_email_not_sent
      end
    end
  end
end