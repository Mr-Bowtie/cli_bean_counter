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
    @start_date = grab_start_date
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

  def grab_start_date
    # puts "Enter a start date (yyyy-mm-dd)"
    # input = gets.chomp
    Date.parse(ARGV[0])
  end



  def sum_bills_in_period
    # TODO: extract 
    date_numbers = []
    for date in @date_range
      date_numbers.push(date.day)
    end

    # create an array of all the bills with due dates in the date range
    bills_to_pay = @bills["monthly_bills"].select{|bill| date_numbers.include?(bill["date_number"])}
    bills_to_pay += @bills["every_check"]
    
    # sum the payments 
    bills_to_pay.reduce(0) {|memo, bill| memo += bill["amount"]}
  end
end

def 

bean_counter = BeanCounter.new
p bean_counter.sum_bills_in_period


