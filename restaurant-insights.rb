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
        puts search_restaurants(params)
      when "2"
        puts dishes_list
      when "3"
        puts "execute 3"
      when "4"
          puts top10_visitors
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
  
  def search_restaurants(params)
    # title=ring | author=prof | publisher=mac -> field=term
  
    if params = "1"
      query= "SELECT r.id,r.restaurant_name,r.category,r.city
      FROM restaurant AS r"
      result = @conn.exec(query)
      create_table(result, "List of restaurants")
    else
      field, term = params.split("=")
      column_by_field = {
      "category" => "r.category",
      "city" => "r.city"
       }
      query = "SELECT r.id,r.restaurant_name,r.category,r.city
      FROM restaurant AS r
      WHERE LOWER(#{column_by_field[field]}) LIKE '%#{term.downcase.gsub("'", "''")}%';"
  
      result = @conn.exec(query)
      create_table(result, "List of restaurants")
    end
  end

  def dishes_list
    query = "SELECT DISTINCT dish AS name 
            FROM dishes 
            ORDER BY dish;"

    result = @conn.exec(query)
    create_table(result, "List of dishes")
  end

  def top10_visitors
    query ="SELECT r.restaurant_name AS name ,COUNT(o.visit_date) AS visitors
    FROM restaurant AS r
    JOIN orders AS o ON r.id = o.restaurant_id
    GROUP BY name
    ORDER BY visitors DESC
    LIMIT 10;"

    result = @conn.exec(query)
    create_table(result, "Top 10 restaurants by visitors")
  end

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

  def create_table(result, title)
    table = Terminal::Table.new
    table.title = title
    table.headings = result.fields
    table.rows = result.values
    table.style = {:all_separators => true}
    table
  end


end

insights = Insights.new
insights.start


