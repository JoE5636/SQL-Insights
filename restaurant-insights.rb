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
        puts clients_percentage(params)
      when "4"
          puts top10_visitors
      when "5"
          puts top_restaurants
      when "6"
          puts top_avg_expense
      when "7"
          puts average_expense(params)
      when "8"
          puts sales_by_month(params)
      when "9" 
          puts lower_price
      when "10"
          puts fovorite_dish(params)
      when "menu"
        print_menu
      when "exit"
        break
      else
        puts "Invalid option"
      end
    end
  end

 
  def fovorite_dish(params)
    field, term = params.split("=")

    query = "SELECT CONCAT(#{field}, '') AS #{field}, d.dish AS \"Favorite dish\", COUNT(*) AS count
    FROM orders o
    JOIN dishes d ON d.id = o.dishes_id
    JOIN client c ON c.id = o.client_id
    WHERE c.#{field} ='#{term}'
    GROUP BY #{field}, d.dish
    ORDER BY count DESC
    LIMIT 1;"

    result = @conn.exec(query)
    create_table(result, "List of dishes")
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


  def clients_percentage(params)
    _group, option = params.split("=")
      column = {
      "age" => "client.age",
      "gender" => "client.gender",
      "occupation" => "client.occupation",
      "nationality" => "client.nationality"
      }
      query = "SELECT #{column[option]}, COUNT(#{column[option]}) AS count, 
      ROUND(COUNT(#{column[option]}) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
      FROM client
      GROUP BY #{column[option]}
      ORDER BY #{column[option]};"
  
      result = @conn.exec(query)
      create_table(result, "Number and Distribution of Users")
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

  def top_restaurants
    query = "SELECT restaurant_name, SUM(price) AS sales
            FROM orders AS o
            JOIN restaurant AS r ON o.restaurant_id = r.id
            GROUP BY restaurant_name
            ORDER BY sales DESC
            LIMIT 10;"

    result = @conn.exec(query)
    create_table(result, "Top 10 restaurants by sales")
  end

  def top_avg_expense
    query = "SELECT restaurant_name, ROUND(AVG(price),1) AS expense
            FROM orders AS o
            JOIN restaurant AS r ON o.restaurant_id = r.id
            GROUP BY restaurant_name
            ORDER BY expense DESC
            LIMIT 10;"

    result = @conn.exec(query)
    create_table(result, "Top 10 restaurants by average expense per user")
  end

  def average_expense(params)
   _group, option = params.split("=")
    column = {
      "age" => "client.age",
      "gender" => "client.gender",
      "occupation" => "client.occupation",
      "nationality" => "client.nationality"
    }
    query = "SELECT #{option}, ROUND(AVG(orders.price),2) as avg_expense
    FROM client
    JOIN orders ON orders.client_id = client.id
    GROUP BY #{column[option]}
   ORDER by #{option};"
  
      result = @conn.exec(query)
      create_table(result, "Average consumer expenses")
  end

  def lower_price
    query = "SELECT subquery.dish, subquery.restaurant_name AS restaurant, subquery.price
    FROM (
      SELECT d.dish, r.restaurant_name, o.price,
             ROW_NUMBER() OVER (PARTITION BY d.dish ORDER BY o.price) AS row_num
      FROM orders o
      JOIN restaurant r ON o.restaurant_id = r.id
      JOIN dishes d ON o.dishes_id = d.id
    ) AS subquery
    WHERE subquery.row_num = 1
    ORDER BY subquery.dish ASC;"

    result = @conn.exec(query)
    create_table(result, "Best price for dish ")
  end

  def sales_by_month(params)
    order, option = params.split("=")

    query = "SELECT TO_CHAR(o.visit_date, 'MONTH') AS month, SUM(price) AS sales
            FROM orders AS o
            GROUP BY month
            ORDER BY sales #{option};"
    
    result = @conn.exec(query)
    create_table(result, "Total sales by month")

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


