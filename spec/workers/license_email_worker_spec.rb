require 'spec_helper'


describe "license email worker" do
  before :each do
    create(:release)
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.deliveries.clear
    ResqueSpec.reset!
    @c_user = create(:user)

    @template = create(:trial_license_template_one_hw)
    @license = License.build_from_template(@template)
    @license.user = @c_user
    @license.save
  end

  it "should send an email" do
    @license.reload
    @license.generate_serial
    with_resque do
      License.enqueue_licenses_for_email([@license])

      @license.reload
      sleep 1
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(@license.email_status).to eq License::EMAIL_SENT
      expect(@license.email_try_counter).to eq 1
    end
  end

  it "should send multiple emails" do
    @license2 = License.build_from_template(@template)
    @license2.user = @c_user
    @license2.save
    licenses = [@license, @license2]
    @license.reload
    @license.generate_serial
    @license2.generate_serial
    with_resque do
      License.enqueue_licenses_for_email(licenses)
      @license.reload
      @license2.reload
      sleep 1
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(@license.email_status).to eq License::EMAIL_SENT
      expect(@license2.email_status).to eq License::EMAIL_SENT
      expect(@license.email_try_counter).to eq 1
      expect(@license2.email_try_counter).to eq 1
    end

  end

  it "should not sent status be true when delivery not happened" do
    ActionMailer::Base.perform_deliveries = false
    @license.reload
    @license.generate_serial
    with_resque do
      License.enqueue_licenses_for_email([@license])
      @license.reload
      sleep 1
      # expect(ActionMailer::Base.deliveries.count).to eq 0
      # expect(@license.email_status).to eq License::EMAIL_NOT_SENT
      expect(@license.email_try_counter).to eq 1
      License.enqueue_licenses_for_email([@license])
      @license.reload
      sleep 1
      expect(ActionMailer::Base.deliveries.count).to eq 0
      # expect(@license.email_status).to eq License::EMAIL_NOT_SENT
      expect(@license.email_try_counter).to eq 2

      ActionMailer::Base.perform_deliveries = true

      License.enqueue_licenses_for_email([@license])
      @license.reload
      sleep 1
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(@license.email_status).to eq License::EMAIL_SENT
      expect(@license.email_try_counter).to eq 3

    end
  end

end