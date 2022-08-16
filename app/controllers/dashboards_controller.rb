class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    unless(can? :manage, Report)
      redirect_to user_path(current_user)
    end

  end

  def get_user_reports
    authorize! :manage, Report
    users = User.all
    last_30_day_report = Report.last_30_day_users
    last_users = last_30_day_report.map { |report| {date: report["_id"], value: report["value"]} }.sort_by { |hsh| hsh[:date] }


    respond_to do |format|
      format.json { render json: {all_user: {all: users.count}, last_30_day: last_users}, status: :ok }
    end
  end

  def get_licenses_reports
    authorize! :manage, Report
    licenses = License.all
    all_licenses = {all: licenses.count, demo: licenses.where(license_type: License::DEMO).count, commercial: licenses.where(license_type: License::COMMERCIAL).count}
    last_30_day = Report.last_30_day_licenses.select { |x| x["value"].is_a?(Hash) }.map { |report| {date: report["_id"], demoSum: report["value"]["demoSum"], commercialSum: report["value"]["commercialSum"]} }.sort_by { |hsh| hsh[:date] }
    respond_to do |format|
      format.json { render json: {all_licenses: all_licenses, last_30_day: last_30_day}, status: :ok }
    end
  end

  def get_orders_reports
    authorize! :manage, Report
    orders = Order.all
    all_orders = {all: orders.count, success: orders.where("payment.payment_status" => Payment::STATUS_SUCCESS).count, failed: orders.where("payment.payment_status" => Payment::STATUS_FAILED).count, new: orders.where("payment.payment_status" => Payment::STATUS_NEW).count}
    last_30_day = Report.last_30_day_orders.select { |x| x["value"].is_a?(Hash) }.map { |report| {date: report["_id"], successSum: report["value"]["successSum"], newSum: report["value"]["newSum"], failedSum: report["value"]["failedSum"]} }.sort_by { |hsh| hsh[:date] }
    respond_to do |format|
      format.json { render json: {all_orders: all_orders, last_30_day: last_30_day}, status: :ok }
    end
  end

  def get_payments_reports
    authorize! :manage, Report
    all_payments = Report.all_payment_sum.map{|x| {currency: x["_id"], amount: x["value"]}}
    day30 = Report.last_30_day
    combined = {}
    day30.each do |report|
      combined[report.report_for.beginning_of_day] = combined[report.report_for.beginning_of_day].present? ? combined[report.report_for.beginning_of_day] + report.user_counter : report.user_counter
      # puts "{report_for: new Date(#{report.report_for.beginning_of_day.to_i*1000}), user_counter: #{report.user_counter}}"
    end
    last_30_day = Report.last_30_day_payments
    last_30_day = last_30_day.map do |report|
      splitted = report["_id"].split("|")
      currency = "USD"
      if splitted.size > 1
        currency = splitted[1]
      end
      {date: splitted[0], "#{currency}"=> report["value"]}
    end
    #last_30_day.sort_by { |hsh| hsh[:date] }
    # puts "a"
    respond_to do |format|
      format.json { render json: {all_payments: all_payments, last_30_day: last_30_day}, status: :ok }
    end
  end
end
