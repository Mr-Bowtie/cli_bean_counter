require "yaml"
require "pry"

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

  def sum_bills_in_period()

  end
end

puts BeanCounter.new().sum_all

