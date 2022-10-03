require "require_all"
require_all "lib"
require "cli/ui"

class BeanCounterCli < Thor
  package_name "bean_counter"
  namespace :bean_counter

  attr_accessor :bean_counter

  no_commands do
    def bean_counter
      @bean_counter ||= BeanCounter.new
    end
  end

  desc "list_categories", "List all of the main bill categories you have set up"

  def list_categories
    # type will be an array with the first element being the name of the category
    BeanCounter.new.bills.each do |type|
      puts type[0]
    end
  end

  desc "list_bills", "Choose a category and see all the bills it contains"

  def list_bills
    app = BeanCounter.new
    selection = ""
    CLI::UI::StdoutRouter.enable
    CLI::UI::Prompt.ask("Choose a category to display") do |handler|
      handler.option("all") { |opt| app.display_bills_by_category("all") }
      handler.option("monthly bills") { |opt| app.display_bills_by_category("monthly_bills") }
      handler.option("credit cards") { |opt| app.display_bills_by_category("credit_cards") }
      handler.option("every check") { |opt| app.display_bills_by_category("every_check") }
    end
  end

  desc "list_bills_in_period START_DATE", "Lists bills that are due between START_DATE and END_DATE. dates must be in format yyyy-mm-dd"

  def list_bills_in_period(date)
    app = BeanCounter.new(date)
    app.display_bills_in_period
  end

  desc "pay_period_breakdown START_DATE", "Lists bills due between START_DATE and END_DATE, and shows income calculations."

  def pay_period_breakdown(date)
    # app = BeanCounter.new(date)
    bean_counter.display_bills_in_period
    bean_counter.display_income_calcs
    bean_counter.display_divisions
  end

  desc "edit_bill", "Choose a bill and edit one of it's properties"

  def edit_bill
    CLI::UI::Prompt.ask("Choose a bill to edit") do |handler|
      # TODO: extract this
      bean_counter.bills.each do |bill_type, bill_list|
        bill_list.each do |bill|
          handler.option("#{bill['name']}") {|opt| p opt}
        end 
      end
    end
  end
end
