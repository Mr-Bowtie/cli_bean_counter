require "yaml"
require "pry"
require "date"

class BeanCounter 
  @@bill_file = "config/bills.yml"
  @@config_file = "config/config.yml"
  attr_accessor :bills, :config, :pay_range, :start_date, :date_range
  
  def initialize()
    @bills = YAML.load_file(@@bill_file)
    @config = YAML.load_file(@@config_file)
    @pay_range = @config["pay_range"]
    @start_date = parse_start_date
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

  def parse_start_date
    # date has to be in format yyyy-mm-dd
    Date.parse(ARGV[0])
  end

  def gather_bills_in_period
    date_numbers = []
    for date in @date_range
      date_numbers.push(date.day)
    end

    # create an array of all the bills with due dates in the date range
    bills_to_pay = @bills["monthly_bills"].select{|bill| date_numbers.include?(bill["date_number"])}
    bills_to_pay += @bills["every_check"]
  end

  def sum_bills_in_period 
    gather_bills_in_period.reduce(0) {|memo, bill| memo += bill["amount"]}
  end

  def display_bills_in_range
    puts "------------------------------"
    gather_bills_in_period.each do |bill|
      display_string = "Name: #{bill['name']}, Amount Due: #{bill['amount']}"
      if bill["date_number"]
        display_string += " Date: #{bill['date_number']}" 
      else 
        display_string += " Date: Pay every check"
      end
      puts display_string
      puts "------------------------------"
    end
    puts "Total due: #{sum_bills_in_period}"
  end
end

bean_counter = BeanCounter.new
bean_counter.display_bills_in_range


