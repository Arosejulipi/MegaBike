# MegaBike (Ruby on Rails)

Aplicacion web de ejemplo para una bicicleteria/e-commerce liviano, con:
- Home + pagina "Nosotros"
- Catalogo de productos con filtros (marca, categoria, precio, busqueda)
- Carrito y compra simple (sin pasarela de pago)
- Turnos de service (notifica al negocio y al cliente por email)
- Pedidos de bicicletas personalizadas (presupuesto por email)
- Login/registro de clientes + rol admin
- Panel admin para gestionar productos

## Stack / como se desarrollo
- Ruby on Rails 7
- Bootstrap 5 (UI)
- PostgreSQL en produccion (Render)
- Envio de emails en produccion via Webhook HTTPS (pensado para entornos donde SMTP falla)
- Subida de imagenes de productos via Cloudinary (opcional, recomendado)

## Requisitos (local)
- Ruby 3.2+
- Bundler
- SQLite (dev/test)

## Setup rapido (local)
```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails s
```
Abrir: `http://localhost:3000`

## Produccion (Render): base de datos
En produccion se usa `DATABASE_URL` (PostgreSQL). Un deploy NO borra la base de datos (salvo que se elimine/resetee la DB).

## Admin (produccion)
Para evitar dejar credenciales fijas en produccion, el proyecto soporta crear/actualizar un admin al iniciar, via variables de entorno:
- `SEED_ADMIN_EMAIL` (default: `admin@megabike.com`)
- `SEED_ADMIN_PASSWORD` (requerida para activar el seed)
- `SEED_ADMIN_NAME` (opcional)

Recomendacion: configurar estas variables en Render y cambiar la password por una propia.

## Imagenes de productos
Los productos guardan la foto como `image_url` (un link).

### Opcion A (recomendado): Cloudinary (gratis)
1) Crear una cuenta en Cloudinary
2) Settings -> Upload -> Upload presets -> crear preset:
   - Signing Mode: **Unsigned**
3) En Render cargar:
   - `CLOUDINARY_CLOUD_NAME`
   - `CLOUDINARY_UPLOAD_PRESET`
   - (opcional) `CLOUDINARY_FOLDER` (ej: `megabike/products`)
4) En el panel Admin -> Productos, podes subir un archivo y el sistema completa automaticamente la URL.

### Opcion B: servir imagenes desde la propia app
Podes commitear imagenes en `public/productos/` y usar URLs relativas, por ejemplo:
- `/productos/cubierta.png`
- `/productos/transmisioncompleta.png`

## Email en produccion (Render)
En el plan gratis de Render es comun que conexiones SMTP fallen. Este proyecto soporta envio por Webhook HTTPS:
- `EMAIL_WEBHOOK_URL`
- `EMAIL_WEBHOOK_TOKEN` (opcional, recomendado)

Backend recomendado (gratis): Google Apps Script (GmailApp.sendEmail).

