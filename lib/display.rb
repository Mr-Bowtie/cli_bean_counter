# frozen_string_literal: true

require 'rainbow/refinement'
using Rainbow
module Display
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

    CLI::UI::Frame.open(title) do
      bill_arr.each do |bill|
        display_bill(bill)
      end
    end
  end

  def display_bill(bill)
    display_string = 'Name:'.red +
                     " #{bill['name']}, " +
                     'Amount Due:'.blue +
                     " #{bill['amount']}" +
                     ' Date:'.yellow +
                     " #{bill['date']}"
    puts display_string
  end

  def display_income_calcs
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open('Income Breakdown') do
      puts 'Paycheck: '.yellow + paycheck.to_s
      puts 'Bill total: '.red + sum_bills(gather_bills_in_period).to_s
      puts 'Net: '.green + calculate_net_income.to_s
    end
  end

  def display_divisions(divs: traverse_divisions, name: "Money Buckets: #{calculate_net_income}")
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
end
