# frozen_string_literal: true

require 'require_all'
require_all 'lib'
require 'cli/ui'
require 'yaml/store'
require 'date'

# CLI commands and helpers
class BeanCounterCli < Thor
  package_name 'bean_counter'
  namespace :bean_counter

  # attr_accessor :bean_counter

  no_commands do
    def edit_bill_attributes(bill_type:, bill:)
      CLI::UI::Prompt.ask('Choose attribute to edit') do |handler|
        # display all editable attributes
        bill.each do |key, _|
          handler.option(key.to_s) do |opt|
            store = YAML::Store.new 'config/bills.yml'
            input = CLI::UI.ask('Enter the new value', default: (bill[opt]).to_s)
            # add in logic to skip transaction if value didn't change
            # input will be a string by default, need it to be and integer for amount and date_number
            input = input.to_i unless opt == 'name'
            # all operations on store need to happen in a transaction
            # All of this happens or none of it
            store.transaction do
              bill_index = store[bill_type].index(bill)
              # update the correct field in the YAML file
              store[bill_type][bill_index][opt] = input
              # implicitly return the updated bill
              store[bill_type][bill_index]
            end
          end
        end
      end
    end
  end

  desc 'list_categories', 'List all of the main bill categories you have set up'

  def list_categories
    # type will be an array with the first element being the name of the category
    BeanCounter.new.bills.each do |type|
      puts type[0]
    end
  end

  desc 'list_bills', 'Choose a category and see all the bills it contains'

  def list_bills
    app = BeanCounter.new
    selection = ''
    CLI::UI::StdoutRouter.enable
    CLI::UI::Prompt.ask('Choose a category to display') do |handler|
      handler.option('all') { |_opt| app.display_bills_by_category('all') }
      handler.option('monthly bills') { |_opt| app.display_bills_by_category('monthly_bills') }
      handler.option('credit cards') { |_opt| app.display_bills_by_category('credit_cards') }
      handler.option('every check') { |_opt| app.display_bills_by_category('every_check') }
    end
  end

  desc 'list_bills_in_period START_DATE',
       'Lists bills that are due between START_DATE and END_DATE. dates must be in format yyyy-mm-dd'

  def list_bills_in_period(date)
    app = BeanCounter.new(date)
    app.display_bills_in_period
  end

  desc 'pay_period_breakdown START_DATE',
       'Lists bills due between START_DATE and END_DATE, and shows income calculations.'

  def pay_period_breakdown(date)
    bean_counter = BeanCounter.new(date)
    bean_counter.display_bills_in_period
    bean_counter.display_income_calcs
    bean_counter.display_divisions
    bean_counter.display_message_group(bean_counter.messages) unless bean_counter.messages.empty?
  end

  desc 'edit_bill', "Choose a bill and edit one of it's properties"

  def edit_bill
    bean_counter = BeanCounter.new
    loop do
      CLI::UI::Prompt.ask('Choose a bill to edit') do |handler|
        # TODO: extract this
        bean_counter.bills.each do |bill_type, bill_list|
          bill_list.each do |bill|
            handler.option((bill['name']).to_s) do |_opt|
              bean_counter.display_bill(bill)
              # set bill to new value after updating
              bill = edit_bill_attributes(bill_type: bill_type, bill: bill)
              # display updated bill
              bean_counter.display_bill(bill)
            end
          end
        end
      end
      bean_counter.display_edit_bill_replay_message
      answer = $stdin.gets.chomp.downcase
      break unless answer == 'y'

      bean_counter.reload_bills
    end
  end

  desc 'add_message DATE', 'add a message with a specified date to display it (DATE format: yyyy-mm-dd) '
  def add_message(date_string = nil)
    bean_counter = BeanCounter.new
    loop do
      store = YAML::Store.new 'config/messages.yml'

      if date_string.nil?
        date_string = CLI::UI::Prompt.ask('Message date?', default: Date.today.to_s)
      end

      date = Date.parse(date_string)
      input = CLI::UI::Prompt.ask('Enter message body')
      message = { 'date' => date.to_s, 'body' => input.to_s }

      store.transaction do
        # account for empty messages file
        store['messages'] = [] if store['messages'].nil?
        # update the correct field in the YAML file
        store['messages'].push(message)
      end

      bean_counter.display_message(message)
      bean_counter.display_add_message_replay_message
      answer = $stdin.gets.chomp.downcase
      break unless answer == 'y'

      date_string = nil
    end
  end
end
