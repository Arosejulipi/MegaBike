# Mega Bike (Ruby on Rails)

Aplicación web para una bicicletería llamada **Mega Bike**.

Incluye:
- Home / Nosotros
- Productos (público, sin registro) + carrito + “compra” simple (sin pasarela de pago)
- Servicios: agenda de turnos + email al dueño
- Personalizado: presupuesto de bici personalizada + email al dueño
- Login/registro de clientes + rol admin
- Asistente de preguntas frecuentes (simple, sin IA)

> Nota: Este proyecto está pensado para que lo abras en tu PC y hagas `bundle install` allí.
> En este entorno no puedo descargar gems desde internet, por eso te dejo el proyecto completo pero **sin** `Gemfile.lock`.

## Requisitos (en tu PC)
- Ruby 3.1+ (ideal 3.2+)
- Bundler
- Node no es obligatorio (usa Bootstrap por CDN)

## Setup rápido
```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails s
```

Entrá a: http://localhost:3000

### Usuario admin (seed)
- Email: admin@megabike.com
- Password: admin1234

## Email
En desarrollo el mailer está configurado con `letter_opener_web`.
Cuando creás un turno o un pedido de personalizado, se genera un email y lo podés ver en:
http://localhost:3000/letter_opener

En producción (Render/Koyeb) cambiás la config SMTP en variables de entorno.

## Deploy
Incluye `render.yaml` como ejemplo para Render.
