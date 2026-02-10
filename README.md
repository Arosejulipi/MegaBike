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
- Password: `admin12345`

## Imagenes de productos (Cloudinary - recomendado)
Los productos guardan la foto como `image_url` (un link).
Para no depender de SMTP/archivos, se recomienda Cloudinary (plan gratis).

### 1) Cloudinary: crear preset unsigned
1) Crear una cuenta en Cloudinary
2) Ir a **Settings -> Upload**
3) Crear un **Upload preset**:
   - Mode: **Unsigned**
   - (opcional) Folder: `megabike/products`
   - (opcional) Allowed formats: jpg/png/webp

### 2) Render: variables de entorno
Agregar en Render:
- `CLOUDINARY_CLOUD_NAME` = tu cloud name (ej: `dxxxxx`)
- `CLOUDINARY_UPLOAD_PRESET` = nombre del preset unsigned (ej: `megabike_unsigned`)
- (opcional) `CLOUDINARY_FOLDER` = `megabike/products`

### 3) Admin: subir foto desde el form
En `/admin/products/new` o editar:
- Elegir archivo en "Subir foto" y automaticamente se sube a Cloudinary
- El sistema completa `Foto (URL)` con la URL final

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

Importante: no uses Postmark. Si en Render tenes cargada la variable `POSTMARK_API_TOKEN`, borrala para evitar que el deploy anterior intente usar Postmark.

## Render (gratis): alternativa recomendada (sin SMTP) - Webhook por HTTPS
En el plan gratis de Render es comun que las conexiones SMTP (por ejemplo a `smtp.gmail.com:587`) fallen con `Net::OpenTimeout`.
La alternativa mas simple es enviar emails por HTTPS a un Webhook.

Este proyecto soporta un webhook por variables:
- `EMAIL_WEBHOOK_URL` (URL de tu webhook)
- `EMAIL_WEBHOOK_TOKEN` (opcional, recomendado)

Backend recomendado (gratis): Google Apps Script (usa tu Gmail).
1) Ir a https://script.google.com/ y crear un proyecto
2) Pegar este codigo:
```javascript
const TOKEN = PropertiesService.getScriptProperties().getProperty("EMAIL_WEBHOOK_TOKEN") || "";

function handleSend(to, subject, textBody, htmlBody) {
  GmailApp.sendEmail(to, subject, textBody || " ", { htmlBody: htmlBody || "" });
  return ContentService.createTextOutput("OK").setMimeType(ContentService.MimeType.TEXT);
}

function isAuthorized(e) {
  const auth = (e && e.parameter && e.parameter.token) ? e.parameter.token : "";
  const header = (e && e.headers && (e.headers.Authorization || e.headers.authorization)) || "";
  const bearer = header.startsWith("Bearer ") ? header.slice(7) : "";
  const token = bearer || auth || "";
  return !(TOKEN && token !== TOKEN);
}

// GET is recommended (works reliably with Apps Script hosting redirects).
function doGet(e) {
  try {
    if (!isAuthorized(e)) {
      return ContentService.createTextOutput("Unauthorized").setMimeType(ContentService.MimeType.TEXT);
    }

    const to = ((e && e.parameter && e.parameter.to) || "").toString();
    const subject = ((e && e.parameter && e.parameter.subject) || "").toString();
    const htmlBody = ((e && e.parameter && e.parameter.html) || "").toString();
    const textBody = ((e && e.parameter && e.parameter.text) || "").toString();

    return handleSend(to, subject, textBody, htmlBody);
  } catch (err) {
    return ContentService.createTextOutput("ERR: " + err).setMimeType(ContentService.MimeType.TEXT);
  }
}

// Optional: POST support (not always reliable depending on redirects)
function doPost(e) {
  try {
    if (!isAuthorized(e)) {
      return ContentService.createTextOutput("Unauthorized").setMimeType(ContentService.MimeType.TEXT);
    }

    const data = JSON.parse((e && e.postData && e.postData.contents) || "{}");
    const to = (data.to || "").toString();
    const subject = (data.subject || "").toString();
    const htmlBody = (data.html || "").toString();
    const textBody = (data.text || "").toString();

    return handleSend(to, subject, textBody, htmlBody);
  } catch (err) {
    return ContentService.createTextOutput("ERR: " + err).setMimeType(ContentService.MimeType.TEXT);
  }
}
```
3) En el menu: Project Settings -> Script properties, crear `EMAIL_WEBHOOK_TOKEN` con un valor random
4) Deploy -> New deployment -> Web app
   - Execute as: Me
   - Who has access: Anyone
5) Copiar la URL del deployment y ponerla en Render como `EMAIL_WEBHOOK_URL`
6) Poner el mismo token en Render como `EMAIL_WEBHOOK_TOKEN`
