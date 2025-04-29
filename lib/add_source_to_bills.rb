require 'yaml'
require 'pry'

bills = YAML.load_file('config/bills.yml')

bills['bills'].each do |bill|
  bill['source'] = ''
end

File.open('config/bills.yml', 'w') { |file| file.write(bills.to_yaml) }
