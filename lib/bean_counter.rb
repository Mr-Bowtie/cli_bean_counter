require "yaml"
require "rainbow/refinement"
require "pry"
require "date"
using Rainbow 

class App 
  @@bill_file = "config/bills.yml"
  @@config_file = "config/config.yml"
  attr_accessor :bills, :config, :pay_range, :start_date, :date_range, :paycheck
  
  def initialize(date)
    @bills = YAML.load_file(@@bill_file)
    @config = YAML.load_file(@@config_file)
    @pay_range = @config["pay_range"]
    @paycheck = @config["default_paycheck"]
    @start_date = parse_start_date(date)
    # @date_range = @start_date..(@start_date + @pay_range)
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

  def date_range 
    @start_date..(@start_date + @pay_range)
  end

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

  def display_bills_in_range
    CLI::UI::Frame.open("Bills") do 
      gather_bills_in_period.each do |bill|
        display_bill(bill)
      end
      puts "Total due:".red + " #{sum_bills_in_period}"
    end 
  end

  def display_bills(scope) 
    puts "-------------------------------------------".green
    if scope == "all"
      @bills.each do |type, bills|
        bills.each do |bill|
          display_bill(bill)
          puts "-------------------------------------------".green
        end
      end
    else 
      @bills[scope].each do |bill|
        display_bill(bill)
        puts "-------------------------------------------".green
      end
    end
  end

  def display_bill(bill)
    display_string = "Name:".red + " #{bill['name']}, " + "Amount Due:".blue + " #{bill['amount']}"
    if bill["date_number"]
      display_string += " Date:".yellow + " #{bill['date_number']}" 
    else 
      display_string += " Date:".yellow + " Pay every check"
    end
    puts display_string
  end
end



