require "yaml"
require "pry"
require "date"

class BeanCounter 
  @@bill_file = "config/bills.yml"
  @@config_file = "config/config.yml"
  attr_accessor :bills, :config, :pay_range
  
  def initialize()
    @bills = YAML.load_file(@@bill_file)
    @config = YAML.load_FILE(@@config_file)
    @pay_range = @config["pay_range"]
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


  def sum_bills_in_period(date_range)
    date_numbers = []
    for date in date_range
      date_numbers.push(date.day)
    end

    # create an array of all the bills with due dates in the date range
    bills_to_pay = @bills["monthly_bills"].select{|bill| date_numbers.include?(bill["date_number"])}
    
    # sum the payments 
    bills_to_pay.reduce(0) {|memo, bill| memo += bill["amount"]}
  end
end

def 

  range = Date.today..( Date.today + bean_counter.pay_range)
bean_counter = BeanCounter.new
p bean_counter.sum_bills_in_period(range)


