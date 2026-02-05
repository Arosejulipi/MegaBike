# Mega Bike (Ruby on Rails)

Aplicacion web para una bicicleteria llamada **Mega Bike**.

Incluye:
- Home / Nosotros
- Productos (publico, sin registro) + carrito + compra simple (sin pasarela de pago)
- Servicios: agenda de turnos + emails (negocio y cliente)
- Personalizado: presupuesto de bici personalizada + email al negocio
- Login/registro de clientes + rol admin
- FAQ simple

## Requisitos (en tu PC)
- Ruby 3.1+ (ideal 3.2+)
- Bundler

## Setup rapido
```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails s
```

Entrar a: `http://localhost:3000`

### Usuario admin (seed)
- Email: `admin@megabike.com`
- Password: `admin1234`

## Email en desarrollo
En desarrollo el mailer esta configurado con `letter_opener_web`.
Ver emails en: `http://localhost:3000/letter_opener`

## Produccion (Render): variables de entorno (SMTP)
Importante: Render no trae un SMTP gratis. Para enviar emails en produccion necesitas configurar un SMTP (por ejemplo Gmail).

Variables minimas:
- `ADMIN_EMAILS` (a donde le llega al negocio, uno o varios separados por coma)
- `DEFAULT_FROM_EMAIL` (remitente)
- `APP_HOST` (ej: `megabike.onrender.com`)
- `APP_PROTOCOL` = `https`

SMTP (Gmail):
- `SMTP_ADDRESS` = `smtp.gmail.com`
- `SMTP_PORT` = `587`
- `SMTP_USERNAME` = tu gmail completo (ej: `ayleeenmaliandi@gmail.com`)
- `SMTP_PASSWORD` = App Password de Google (no es tu clave normal)
- `SMTP_AUTHENTICATION` = `plain`
- `SMTP_ENABLE_STARTTLS_AUTO` = `true`

Nota: para obtener `SMTP_PASSWORD` en Gmail, Google pide tener activada la verificacion en 2 pasos y luego crear una "contrasena de aplicacion".
