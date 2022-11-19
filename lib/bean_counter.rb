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
  attr_accessor :bills, :config, :pay_range, :start_date, :date_range, :paycheck, :divisions, :net_income

  def initialize(date = Date.today.to_s)
    @bill_path = 'config/bills.yml'
    @config_path = 'config/config.yml'
    @bills = YAML.load_file(@bill_path)
    @config = YAML.load_file(@config_path)
    @pay_range = @config['pay_range']
    @paycheck = @config['default_paycheck']
    # @net_income = calculate_net_income
    @start_date = parse_start_date(date)
    @date_range = @start_date..(@start_date + @pay_range)
    @divisions = @config['dividing_rules']
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
    # TODO: extract logic to filter the fills
    bills_to_pay = (bills['monthly_bills'] + bills['credit_cards']).select do |bill|
      date_numbers.include?(bill['date_number'])
    end
    bills_to_pay + bills['every_check']
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
end
