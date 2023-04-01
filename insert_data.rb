require "csv"
require "pg"

# capturar el argumento de la linea de comandos
csv_path = ARGV[0] # "books.csv"
ARGV.clear

# Conectarnos a BBDD booking
CONN = PG.connect(dbname: "insights")

# Crear un metodo que inserte registros unicos en la BBDD

# Crear un metodo que inserte registros unicos en la BBDD

def create(table_name, data)
  sql = "INSERT INTO #{table_name} (#{data.keys.join(', ')})
  VALUES (#{data.values.map { |v| "'#{v}'" }.join(', ')}) RETURNING *;"

  result = CONN.exec(sql)
  result[0]
end

def find(table_name, data, unique_col)
  result = CONN.exec("SELECT * FROM #{table_name} WHERE #{unique_col} = '#{data[unique_col]}';")

  result.values.empty? ? nil : result[0]
end

def find_or_create(table_name, data, unique_col = nil)
  # Si nos pasan unique_col entonces definimos record, sino queda en nil
  record = unique_col ? find(table_name, data, unique_col) : nil

  # Si record esta definido (quiere decir lo econtramos) entonces lo retornamos, sino lo creamos
  record || create(table_name, data)
end

# Leer archivo CSV y crear registros por cada fila
CSV.foreach(csv_path, headers: true) do |row|
  client_data = {
    "client_name" => row["client_name"],
    "age" => row["age"],
    "gender" => row["gender"],
    "occupation" => row["occupation"],
    "nationality" => row["nationality"]
  }
  client = find_or_create("client", client_data, "client_name")

  restaurant_data = {
    "restaurant_name" => row["restaurant_name"],
    "category" => row["category"],
    "city" => row["city"],
    "address" => row["address"]  
  }
  restaurant = find_or_create("restaurant", restaurant_data, "restaurant_name")  

  dishes_data = {
    "dish" => row["dish"]    
  }
  dishes = find_or_create("dishes", dishes_data)
    
  orders_data = {
    "restaurant_id" => restaurant["id"],
    "dishes_id" => dishes["id"],
    "price" => row["price"],
    "visit_date" => row["visit_date"],
    "client_id" => client["id"]
  }
  orders_data = find_or_create("orders", orders_data)

end