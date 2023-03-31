CREATE TABLE restaurant (
  id SERIAL PRIMARY KEY,
  restaurant_name VARCHAR(255) NOT NULL,
  category VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL
);

CREATE TABLE client (
  id SERIAL PRIMARY KEY,
  client_name VARCHAR(255) NOT NULL, 
  age INTEGER,
  gender VARCHAR(6),
  occupation VARCHAR(255),
  nationality VARCHAR(255),
  restaurant_id INTEGER NOT NULL REFERENCES restaurant
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  dish VARCHAR(255) NOT NULL,
  price INTEGER NOT NULL,
  visit_date DATE
);

CREATE TABLE client_order (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders,
  client_id INTEGER NOT NULL REFERENCES client
);

CREATE TABLE restaurant_order (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders,
  restaurant_id INTEGER NOT NULL REFERENCES restaurant
);