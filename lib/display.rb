# frozen_string_literal: true

require 'rainbow/refinement'
using Rainbow
module Display
  # FIX: this expects methods to be available in the class this module is included in. Bad design.
  def display_bills_in_period
    display_bills(gather_bills_in_period, date_range.to_s)
  end

  def display_bills_by_tag(tag)
    if tag == 'all'
      bills.each do |type, bill_list|
        display_bills(bill_list, type)
      end
    else
      tagged_bills = bills.values.flatten.select { |b| b['tags'].include?(tag) }
      display_bills(tagged_bills, tag)
    end
  end

  def display_bills(bill_arr, title)
    CLI::UI::StdoutRouter.enable

    tablify_bills!(bill_arr)
    CLI::UI::Frame.open(title) do
      bill_arr.each do |bill|
        display_bill(bill)
      end
    end
  end

  def display_bill(bill)
    display_string = 'Name:'.red +
                     " #{bill['name']} " +
                     'Amount Due:'.blue +
                     " #{bill['amount']}" +
                     ' Date:'.yellow +
                     " #{bill['date']}"
    puts display_string
  end

  # FIX: inject these values instead of expecting them to be defined
  def display_income_calcs
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open('Income Breakdown') do
      puts 'Paycheck: '.yellow + paycheck.to_s
      puts 'Bill total: '.red + bill_total.to_s
      puts 'Net: '.green + net_income.to_s
    end
  end

  def display_divisions(divs: traverse_divisions, name: "Money Buckets: #{net_income}")
    CLI::UI.frame_style = :bracket
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open(name) do
      divs.each do |div_name, value|
        next if div_name == :total

        if value.instance_of?(Hash)
          display_divisions(divs: value, name: "#{div_name}: #{value[:total]}")
        else
          puts div_name.green + ": #{value}"
        end
      end
      # p traverse_divisions
    end
  end

  def display_edit_bill_replay_message
    puts '-----------------------------------------'
    puts 'Edit another bill?'.green + ' (y/n)'.red
  end

  def display_add_message_replay_message
    puts '-----------------------------------------'
    puts 'add another message?'.green + ' (y/n)'.red
  end

  def display_message_group(group)
    CLI::UI::Frame.open('Messages'.yellow) do
      group.each do |message|
        display_message(message)
      end
    end
  end

  def display_message(message)
    puts "#{message['date']}: #{message['body']}"
  end

  # expects array of bill hashes
  def tablify_bills!(sorted_bills)
    # for each section
    # find the item of greatest width
    # for all other elements append whitespace to match that width + 1
    # create row for each bill
    sorted_bills.first.each_key do |section|
      next if section == 'tags'

      sectioned_values = sorted_bills.map { |b| b[section] }
      biggest = sectioned_values.max { |a, b| a.to_s.length <=> b.to_s.length }.to_s
      padded_values = sectioned_values.map { |b| b.to_s.ljust(biggest.length + 1) }
      sorted_bills.each_with_index { |b, index| b[section] = padded_values[index] }
      # reassign section values to new values with whitespace
    end
  end

  def bill_table_row(bill); end
end
