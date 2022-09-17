require "yaml"

bills = YAML.load_file('bills.yml')


puts bills["bills"].reduce(0){|memo,bill|
  puts bill["amount"]
  memo += bill["amount"]
}
