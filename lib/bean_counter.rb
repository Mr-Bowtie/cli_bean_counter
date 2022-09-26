require "yaml"
require "rainbow/refinement"
require "pry"
require "date"
require "require_all"
require_all "lib"
using Rainbow 

class App 
  include Display
  @@bill_file = "config/bills.yml"
  @@config_file = "config/config.yml"
  attr_accessor :bills, :config, :pay_range, :start_date, :date_range, :paycheck
  
  def initialize(date = Date.today.to_s)
    @bills = YAML.load_file(@@bill_file)
    @config = YAML.load_file(@@config_file)
    @pay_range = @config["pay_range"]
    @paycheck = @config["default_paycheck"]
    @start_date = parse_start_date(date)
    @date_range = @start_date..(@start_date + @pay_range)
  end

  # iterate through each bill group, then iterate through each bill in that group
  # add each bills dollar amount to a memo object
  def sum_all 
    memo = 0 
    @bills.each do |type| 
      type[1].each {|bill| 
        memo += bill["amount"]}
    end
    memo
  end 

  def parse_start_date(date)
    # date has to be in format yyyy-mm-dd
    # TODO: add try catch for inproperly formatted date input
    Date.parse(date)
  end

  # def date_range 
  #   @start_date..(@start_date + @pay_range)
  # end

  # TODO: get relavant categories from instance variable, instead of hardcoding which ones to display.  
  def gather_bills_in_period
    date_numbers = []
    for date in date_range
      date_numbers.push(date.day)
    end

    # create an array of all the bills with due dates in the date range
    bills_to_pay = @bills["monthly_bills"].select{|bill| date_numbers.include?(bill["date_number"])}
    bills_to_pay += @bills["every_check"]
  end

  def sum_bills_in_period 
    gather_bills_in_period.reduce(0) {|memo, bill| memo += bill["amount"]}
  end

end



