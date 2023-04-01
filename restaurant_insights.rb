require "pg"
require "terminal-table"

class Insights
  def initialize
    @conn = PG.connect(dbname: "insights")
  end

  def start
    print_welcome
    print_menu

    loop do
      print "> "
      option, params = gets.chomp.split

      case option
      when "1"
        puts "execute 1"
      when "2"
        puts "execute 2"
      when "3"
        puts "execute 3"
    when "4"
        puts "execute 4"
    when "5"
        puts "execute 5"
    when "6"
        puts "execute 6"
    when "7"
        puts "execute 7"
    when "8"
        puts "execute 8"
    when "9"
        puts "execute 9"
    when "10"
        puts "execute 10"
      when "menu"
        print_menu
      when "exit"
        break
      else
        puts "Invalid option"
      end
    end
  end



  def 


  def print_welcome
    puts "Welcome to the Restaurants Insights!"
    puts "Write 'menu' at any moment to print the menu again and 'quit' to exit."
  end

  def print_menu()
    puts "---"
    puts "1. List of restaurants included in the research filter by ['' | category=string | city=string]"
    puts "2. List of unique dishes included in the research"
    puts "3. Number and distribution (%) of clients by [group=[age | gender | occupation | nationality]]"
    puts "4. Top 10 restaurants by the number of visitors."
    puts "5. Top 10 restaurants by the sum  of sales."
    puts "6. Top 10 restaurants by the average expense of their clients."
    puts "7. The average consumer expense group by [group=[age | gender | occupation | nationality]]"
    puts "8. The total sales of all the restaurants group by month [order=[asc | desc]]"
    puts "9. The list of dishes and the restaurant where you can find it at a lower price."
    puts "10. The favorite dish for [age=number | gender=string | occupation=string | nationality=string]"
    puts "---"
    puts "Pick a number from the list and an [option] if necessary"
  end

  
end

insights = Insights.new
insights.start


