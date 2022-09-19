require "./app/bean_counter.rb"
require "cli/ui"
class BeanCounter < Thor 
  package_name "bean_counter"
  
  attr_accessor :bean_counter
  # @bean_counter = App.new

  desc "list_categories", "List all of the main bill categories you have set up"
  def list_categories  
    # type will be an array with the first element being the name of the category
    App.new.bills.each do |type|
      puts type[0]
    end 
  end


  desc "list_bills", "Choose a category and see all the bills it contains"
  def list_bills 
    app = App.new
    selection = ""
    CLI::UI::StdoutRouter.enable
    CLI::UI::Prompt.ask("Choose a category to display")do |handler|
      handler.option("all") {|opt| app.display_bills("all") }
      handler.option("monthly bills") {|opt| app.display_bills("monthly_bills")}
      handler.option("credit cards") {|opt| app.display_bills("credit_cards")}
      handler.option("every check") {|opt| app.display_bills("every_check")}
    end
  end

  desc "list_bills_in_period START_DATE", "Lists bills that are due between START_DATE and END_DATE. dates must be in format yyyy-mm-dd"
  def list_bills_in_period(date)
    app = App.new(date)
    app.display_bills_in_range
  end
end
