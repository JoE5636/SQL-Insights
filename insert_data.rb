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
  VALUES (#{data.values.map { |v| "'#{v}'" }.join(', ')}) RETURNING *;"

  result = CONN.exec(sql)
  result[0]
end

def find(table_name, data, unique_col)
  result = CONN.exec("SELECT * FROM #{table_name} WHERE #{unique_col} = '#{data[unique_col].gsub("'", "''")}';")

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
  restaurant_data = {
    "name" => row["restaurant_name"],
    "category" => row["category"],
    "city" => row["city"],
    "address" => row["address"]
  }
  restaurant = create("restaurant", restaurant_data)

  # publisher_data = {
  #   "name" => row["publisher_name"],
  #   "annual_revenue" => row["publisher_annual_revenue"],
  #   "founded_year" => row["publisher_founded_year"]
  # }
  # publisher = find_or_create("publishers", publisher_data, "name")

  # genres_data = { "name" => row["genre"] }
  # genre = find_or_create("genres", genres_data, "name")

  # books_data = {
  #   "title" => row["title"],
  #   "pages" => row["pages"],
  #   "author_id" => author["id"],
  #   "publisher_id" => publisher["id"]
  # }
  # books = create("books", books_data, "title")

  # books_genres_data = { "book_id" => book["id"], "genre_id" => genre["id"] }
  # find_or_create("books_genres", books_genres_data)
end