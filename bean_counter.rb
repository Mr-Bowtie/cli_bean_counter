require "yaml"
require "pry"

bills = YAML.load_file('bills.yml')


# iterate through each bill group, then iterate through each bill in that group
# add each bills dollar amount to a memo object
memo = 0 
bills.each do |type| 
  type[1].each {|bill| 
    memo += bill["amount"]}
end
puts memo


