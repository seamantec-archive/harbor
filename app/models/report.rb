class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :payment_reports

  field :report_for, type: Time
  validates_uniqueness_of :report_for

  field :user_counter, type: Integer
  field :paying_user_counter, type: Integer

  field :license_counter, type: Integer
  field :demo_license_counter, type: Integer
  field :commercial_license_counter, type: Integer

  field :order_counter, type: Integer
  field :success_order_counter, type: Integer
  field :new_order_counter, type: Integer
  field :failed_order_counter, type: Integer


  #payments(sum, by currency)
  #not sent emails

  def self.last_30_day_users
    map = %Q{
      function() {
          emit(this.report_for.getUTCFullYear() + "-" + (this.report_for.getUTCMonth()+1) + "-"+(this.report_for.getUTCDate() < 10 ? "0" : "")+this.report_for.getUTCDate()   , this.user_counter);
      }
    }

    reduce = %Q{
      function(reportFor, userCounter) {
          return Array.sum(userCounter);
      }
    }
    Report.last_30_day.all.map_reduce(map, reduce).out(inline: true)
  end

  def self.last_30_day_licenses
    map = %Q{
         function() {
             emit(this.report_for.getUTCFullYear() + "-" + (this.report_for.getUTCMonth()+1) + "-"+(this.report_for.getUTCDate() < 10 ? "0" : "")+this.report_for.getUTCDate(), [this.demo_license_counter, this.commercial_license_counter]);
         }
       }

    reduce = %Q{
         function(reportFor, licenses) {
             var demoSum = 0;
             var comSum = 0;
             for(var i=0;i<licenses.length;i++){
                 demoSum += licenses[i][0];
                 comSum += licenses[i][1];
             }
             return {demoSum: demoSum, commercialSum: comSum};
       }
       }
    Report.last_30_day.all.map_reduce(map, reduce).out(inline: true)
  end

  def self.last_30_day_orders

    map = %Q{
         function() {
             emit(this.report_for.getUTCFullYear() + "-" + (this.report_for.getUTCMonth()+1) + "-"+(this.report_for.getUTCDate() < 10 ? "0" : "")+this.report_for.getUTCDate(), [this.success_order_counter, this.new_order_counter, this.failed_order_counter]);
         }
       }

    reduce = %Q{
         function(reportFor, licenses) {
             var successSum = 0;
             var newSum = 0;
             var failedSum = 0;
             for(var i=0;i<licenses.length;i++){
                 successSum += licenses[i][0];
                 newSum += licenses[i][1];
                 failedSum += licenses[i][2];
             }
             return {successSum: successSum, newSum: newSum, failedSum: failedSum};
       }
       }
    Report.last_30_day.all.map_reduce(map, reduce).out(inline: true)
  end

  def self.all_payment_sum
    map = %Q{
           function(){
             for(var i in this.payment_reports){
                             emit(this.payment_reports[i].currency, this.payment_reports[i].amount);
                         }
            }
        }

    reduce = %Q{
      function(reportFor, paymentAmount) {

                return Array.sum(paymentAmount);
            }
    }
    Report.all.map_reduce(map, reduce).out(inline: true)
  end
  def self.last_30_day_payments
    map = %Q{
           function(){
              if(this.payment_reports != null){
                 for(var i in this.payment_reports){
                                 emit(this.report_for.getUTCFullYear() + "-" + (this.report_for.getUTCMonth()+1) + "-"+(this.report_for.getUTCDate() < 10 ? "0" : "")+this.report_for.getUTCDate() +"|" + this.payment_reports[i].currency, this.payment_reports[i].amount);
                             }
              }else{
                      emit(this.report_for.getUTCFullYear() + "-" + (this.report_for.getUTCMonth()+1) + "-"+(this.report_for.getUTCDate() < 10 ? "0" : "")+this.report_for.getUTCDate(), 0)
                  }
            }
        }

    reduce = %Q{
      function(reportFor, paymentAmount) {

                return Array.sum(paymentAmount);
            }
    }
    Report.last_30_day.all.map_reduce(map, reduce).out(inline: true)
  end

  def self.last_30_day
    now =Time.now.beginning_of_hour
    Report.where(:report_for.gt => (now-30.days), :report_for.lte => (now)).asc(:report_for)
  end

  def self.create_report_for_datetime(datetime)
    report = Report.find_or_initialize_by(report_for: datetime)

    unless report.new_record?
      return
    end
    users = User.where(:created_at.gte => (datetime), :created_at.lte => (datetime+1.hour))
    orders = Order.where(:created_at.gte => (datetime), :created_at.lte => (datetime+1.hour))
    licenses = License.where(:created_at.gte => (datetime), :created_at.lte => (datetime+1.hour))

    report.user_counter = users.count

    report.license_counter = licenses.count
    report.demo_license_counter = licenses.where(license_type: License::DEMO).count
    report.commercial_license_counter = licenses.where(license_type: License::COMMERCIAL).count

    report.order_counter = orders.count
    report.success_order_counter = orders.where("payment.payment_status" => Payment::STATUS_SUCCESS).count
    report.failed_order_counter = orders.where("payment.payment_status" => Payment::STATUS_FAILED).count
    report.new_order_counter = orders.where("payment.payment_status" => Payment::STATUS_NEW).count

    #payment sum berakasa
    success_orders = orders.where("payment.payment_status" => Payment::STATUS_SUCCESS)
    success_orders.each do |so|
      report.payment_reports << PaymentReport.new(currency: so.payment.currency, amount: so.payment.net_value)
    end
    report.save!
  end

  def self.create_reports
    last_report = Report.last
    if last_report.present?
      start_date = last_report.report_for
    else
      start_date = User.first.created_at
    end

    start_date = start_date.beginning_of_hour
    current_date = start_date
    end_date = Time.now.beginning_of_hour

    while (end_date > current_date) do
      Report.create_report_for_datetime(current_date) if current_date != end_date
      current_date = current_date + 1.hour
    end
  end

end
