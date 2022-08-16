require 'rails_helper'

RSpec.describe Report, :type => :model do
  it "should creat proper reports" do
    @time_now = Time.new(2014, 11, 14, 10, 10, 5, "-00:00")
    Time.stub(:now).and_return(@time_now)

    user1 = build(:user)
    user1.created_at = Time.new(2014, 11, 14, 9, 13, 5, "-00:00")
    user1.save!
    Report.create_reports
    expect(Report.all.size).to eq 1
    expect(Report.first.report_for).to eq Time.new(2014, 11, 14, 9, 0, 0, "-00:00")
    expect(Report.first.user_counter).to eq 1

  end

  it "should start from prev report" do
    @time_now = Time.new(2014, 11, 14, 13, 10, 5, "-00:00")
    Time.stub(:now).and_return(@time_now)
    Report.create(report_for: Time.new(2014, 11, 14, 9, 0, 0, "-00:00"))
    user1 = build(:user)
    user1.created_at = Time.new(2014, 11, 14, 10, 13, 5, "-00:00")
    user1.save!

    Report.create_reports
    expect(Report.all.size).to eq 4
    expect(Report.all[1].report_for).to eq Time.new(2014, 11, 14,10, 0, 0, "-00:00")
    expect(Report.all[1].user_counter).to eq 1
  end
end
