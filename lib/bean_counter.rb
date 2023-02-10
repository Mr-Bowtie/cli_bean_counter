# frozen_string_literal: true

require 'yaml'
require 'date'
require 'require_all'
require_all 'lib'
require 'pry'
require 'pry-byebug'

# Contains core business logic for CLI functionality
class BeanCounter
  include Display
  attr_accessor :bills, :config, :pay_range, :start_date, :date_range, :paycheck, :divisions, :net_income, :messages,
                :tags

  def initialize(date = Date.today.to_s)
    @bill_path = 'config/bills.yml'
    @config_path = 'config/config.yml'
    @messages_path = 'config/messages.yml'
    @bills = YAML.load_file(@bill_path)
    @config = YAML.load_file(@config_path)
    @pay_range = @config['pay_range']
    @paycheck = @config['default_paycheck']
    # @net_income = calculate_net_income
    @start_date = parse_start_date(date)
    @date_range = @start_date..(@start_date + @pay_range)
    @divisions = @config['dividing_rules']
    @messages = messages_in_period
    @tags = collect_tags
  end

  # iterate through each bill group, then iterate through each bill in that group
  # add each bills dollar amount to a memo object
  def sum_all
    memo = 0
    bills.each do |type|
      type[1].each do |bill|
        memo += bill['amount']
      end
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
    date_range.each do |date|
      date_numbers.push(date.day)
    end

    # create an array of all the bills with due dates in the date range
    bills.values.flatten.select do |bill|
      bill['tags'].include?('every check') || date_numbers.include?(bill['date'])
    end
  end

  def sum_bills(bill_arr)
    bill_arr.reduce(0) { |memo, bill| memo + bill['amount'] }
  end

  def calculate_net_income
    paycheck - sum_bills(gather_bills_in_period)
  end

  # TODO: refactor
  # memo is a hash
  # returns hash {name: "example", value: 100}
  def traverse_divisions(divs: divisions, memo: {}, lump: calculate_net_income, parent: nil)
    # iterate over divisions
    # if an object has inner_split, recurse using the memo object to store values
    divs.each do |div|
      # binding.pry
      if div['inner_split']
        if !parent.nil?
          parent[div['name']] = { total: calculate_division(div, lump) }
        else
          memo[div['name']] = { total: calculate_division(div, lump) }
        end
        traverse_divisions(
          divs: div['inner_split'],
          memo: memo,
          lump: calculate_division(div, lump),
          parent: !parent.nil? ? parent[div['name']] : memo[div['name']]
        )
      elsif !parent.nil?
        # binding.pry
        parent[div['name']] = calculate_division(div, lump)
      else
        memo[div['name']] = calculate_division(div, lump)
      end
    end
    memo
  end

  def calculate_division(div, lump)
    (lump * (div['percentage'].to_f / 100)).round(2)
  end

  def reload_bills
    @bills = YAML.load_file(@bill_path)
  end

  # Returns hash: {date:string => body:string}
  # each string being a message body
  # TODO: automate message.yml creation
  def messages_in_period
    return File.new('./config/messages.yml', 'w+') unless File.exist?('./config/messages.yml')

    all_messages = YAML.load_file(@messages_path)['messages']
    return [] if all_messages.nil?

    # only push messages to the memo array if their associated date is within the current date range
    all_messages.filter { |mess| @date_range.include?(Date.parse(mess['date'])) }
  end

  private

  def collect_tags
    @bills.values.flatten.each_with_object([]) { |bill, obj| obj.push(bill['tags']) }.flatten.uniq
  end
end
