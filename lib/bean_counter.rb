require "yaml"
require "pry"
require "pry-byebug"
require "date"
require "require_all"
require_all "lib"

class BeanCounter 
  include Display
  @@bill_file = "config/bills.yml"
  @@config_file = "config/config.yml"
  attr_accessor :bills, :config, :pay_range, :start_date, :date_range, :paycheck, :divisions, :net_income
  
  def initialize(date = Date.today.to_s)
    @bills = YAML.load_file(@@bill_file)
    @config = YAML.load_file(@@config_file)
    @pay_range = @config["pay_range"]
    @paycheck = @config["default_paycheck"]
    # @net_income = calculate_net_income
    @start_date = parse_start_date(date)
    @date_range = @start_date..(@start_date + @pay_range)
    @divisions = @config["dividing_rules"]
  end

  # iterate through each bill group, then iterate through each bill in that group
  # add each bills dollar amount to a memo object
  def sum_all 
    memo = 0 
    bills.each do |type| 
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

  # TODO: get relavant categories from instance variable, instead of hardcoding which ones to display.  
  def gather_bills_in_period
    date_numbers = []
    for date in date_range
      date_numbers.push(date.day)
    end

    # create an array of all the bills with due dates in the date range
    bills_to_pay = bills["monthly_bills"].select{|bill| date_numbers.include?(bill["date_number"])}
    bills_to_pay += bills["every_check"]
  end

  def sum_bills(bill_arr)
    bill_arr.reduce(0) {|memo, bill| memo += bill["amount"]}
  end

  def calculate_net_income
    paycheck - sum_bills(gather_bills_in_period)
  end

  # memo is a hash
  def recurse_divisions(divs:, memo: {}, lump:) 
    # iterate over divisions
    # if an object has inner_split, recurse using the memo object to store values
    # binding.pry
    divs.each do |div|
      if div["inner_split"]
        recurse_divisions(divs: div["inner_split"], memo: memo, lump: calculate_division(div, lump))
      end
      # convert percentage to a decimal 
      memo[div["name"]] = calculate_division(div, lump)

    end
    memo
  end

  def calculate_division(div, lump)
    lump * ( div["percentage"].to_f / 100)    
  end

end



