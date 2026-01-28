# frozen_string_literal: true

# Admin por defecto
User.find_or_create_by!(email: "admin@megabike.com") do |u|
  u.name = "Admin Mega Bike"
  u.password = "admin12345"
  u.password_confirmation = "admin12345"
  u.role = :admin
end

# Algunos productos de ejemplo
samples = [
  { name: "Bicicleta urbana", description: "Ideal para ciudad y trayectos cortos.", price: 250000, stock: 5, active: true },
  { name: "Mountain bike", description: "Para senderos y terrenos irregulares.", price: 420000, stock: 3, active: true },
  { name: "Casco", description: "Protección esencial para andar seguro.", price: 35000, stock: 15, active: true },
  { name: "Luces LED", description: "Juego de luces delantera y trasera.", price: 18000, stock: 20, active: true }
]

samples.each do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) { |p| p.assign_attributes(attrs) }
end
