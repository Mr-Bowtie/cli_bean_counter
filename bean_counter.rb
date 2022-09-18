require "yaml"
require "pry"
require "date"

class BeanCounter 
  @@bill_file = "bills.yml"
  attr_accessor :bills
  
  def initialize()
    @bills = YAML.load_file(@@bill_file)
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
    bills_to_pay = @bills["bills"].select{|bill| date_numbers.include?(bill["date_number"])}
    
    # sum the payments 
    bills_to_pay.reduce(0) {|memo, bill| memo += bill["amount"]}
  end
end

range = Date.today..( Date.today + 14)
bean_counter = BeanCounter.new
p bean_counter.sum_bills_in_period(range)


