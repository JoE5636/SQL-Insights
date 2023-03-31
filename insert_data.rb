require "csv"
require "pg"

# capturar el argumento de la linea de comandos
csv_path = ARGV[0] # "books.csv"
ARGV.clear

# Conectarnos a BBDD booking
CONN = PG.connect(dbname: "insights")

# Crear un metodo que inserte registros unicos en la BBDD

def create(table_name, data)
  sql = "INSERT INTO #{table_name} (#{data.keys.join(', ')})
  VALUES (#{data.values.map { |v| "'#{v.gsub("'", "''")}'" }.join(', ')}) RETURNING *;"

  result = CONN.exec(sql)
  result[0]
end

# def find(table_name, data, unique_col)
#   result = CONN.exec("SELECT * FROM #{table_name} WHERE #{unique_col} = '#{data[unique_col].gsub("'", "''")}';")

#   result.values.empty? ? nil : result[0]
# end

# def find_or_create(table_name, data, unique_col = nil)
#   # Si nos pasan unique_col entonces definimos record, sino queda en nil
#   record = unique_col ? find(table_name, data, unique_col) : nil

#   # Si record esta definido (quiere decir lo econtramos) entonces lo retornamos, sino lo creamos
#   record || create(table_name, data)
# end

# Leer archivo CSV y crear registros por cada fila
CSV.foreach(csv_path, headers: true) do |row|
  restaurant_data = {
    "restaurant_name" => row["restaurant_name"],
    "category" => row["category"],
    "city" => row["city"],
    "address" => row["address"]
  }
  restaurant = create("restaurant", restaurant_data)

  orders_data = {
     "dish" => row["dish"],
     "price" => row["price"],
     "visit_date" => row["visit_date"]
   }
   orders = create("orders", orders_data)

  restaurant_order_data = {
   "order_id" => orders["id"],
   "restaurant_id" => restaurant["id"],
  }
  restaurant_order = create("restaurant_order", restaurant_order_data)
  
  client_data = {
    "client_name" => row["client_name"],
    "age" => row["age"],
    "gender" => row["gender"],
    "occupation" => row["occupation"],
    "nationality" => row["nationality"],
    "restaurant_id" => restaurant["id"]
  }
  client = create("client", client_data)

  client_order_data = {
    "order_id" => orders["id"],
    "client_id" => client["id"],
   }
   client_order = create("client_order", client_order_data)

end