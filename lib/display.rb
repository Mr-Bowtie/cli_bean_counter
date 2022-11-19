require "rainbow/refinement"
using Rainbow 
module Display
  def display_bills_in_period
    display_bills(gather_bills_in_period, date_range.to_s)
  end

  def display_bills_by_category(cat)
    if cat == 'all'
      bills.each do |type, bill_list|
        display_bills(bill_list, type)
      end
    else 
      display_bills(bills[cat], cat)
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
    display_string = "Name:".red + " #{bill['name']}, " + "Amount Due:".blue + " #{bill['amount']}"
    if bill["date_number"]
      display_string += " Date:".yellow + " #{bill['date_number']}" 
    else 
      display_string += " Date:".yellow + " Pay every check"
    end
    puts display_string
  end

  def display_income_calcs
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open("Income Breakdown") do 
      puts "Paycheck: ".yellow + "#{paycheck}"
      puts "Bill total: ".red + "#{sum_bills(gather_bills_in_period)}"
      puts "Net: ".green + "#{calculate_net_income}"
    end
  end

  def display_divisions(divs: traverse_divisions, name: "Money Buckets: #{calculate_net_income}")
    CLI::UI.frame_style = :bracket
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open(name) do 
      divs.each do |name, value|
        next if name == :total
        if value.class == Hash 
          display_divisions(divs: value, name: "#{name}: #{value[:total]}")
        else 
          puts name.green + ": #{value}" 
        end
      end
      # p traverse_divisions
    end
  end

  def display_edit_bill_replay_message
    puts "-----------------------------------------"
    puts "Edit another bill?".green + " (y/n)".red
  end

end
