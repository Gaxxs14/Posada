# Documentación Técnica del Sistema - Posada Pro (v2.5 Cloud & Multiplataforma)

Este documento contiene la especificación técnica completa, arquitectura limpia, modelo de seguridad de grado de producción, endpoints REST y la guía paso a paso para el despliegue en la nube (Render & Neon PostgreSQL) del sistema **Posada Pro**.

---

## 1. Visión General del Sistema

* **Nombre del Sistema:** Posada Pro (Suite Hotelera Integral)
* **Tipo de Aplicación:** Plataforma Integral de Gestión Hotelera, Reservas, Tours y Recepción (Web Responsiva + App Móvil Multiplataforma).
* **Servidor Backend:** C# ASP.NET Core 10 Web API (`/backend`) empaquetado en Docker.
* **Frontend Multiplataforma:** Flutter 3.x (`/frontend`) compatible con Web, Android, iOS y Windows.
* **Base de Datos en la Nube:** PostgreSQL (Neon.tech o Render Cloud).
* **Modelo de Seguridad:** Autenticación por Tokens JWT firmados criptográficamente + Hashing BCrypt de contraseñas + Prevención de Sobreventa (*Zero-Overbooking*) con transacciones atómicas.

---

## 2. Módulos y Funcionalidades Integradas

### 🏨 1. Catálogo y Motor de Reservaciones (Huésped)
* **Catálogo Visual:** Galería de imágenes, comodidades (WiFi, A/C, Smart TV, Jacuzzi, Vista al Mar), capacidad y piso.
* **Cotizador en Tiempo Real:** Cálculo instantáneo del número de noches y total a pagar tanto en **USD** como en **Bs. VES** (con tasa BCV configurable).
* **Prevención de Sobreventa (Zero-Overbooking):** Validación atómica que impide reservas solapadas en la misma habitación.
* **Comprobante Digital con Código QR:** Al reservar, la app genera un código QR único (`POS-2026-XXXX`) para presentar en recepción al momento del check-in.

### 🤖 2. Asistente Virtual Inteligente (AI Hotel Concierge)
* **Chatbot de Atención 24/7:** Asiste a los huéspedes en lenguaje natural respondiendo preguntas sobre atracciones cercanas, playas, horarios de comida, políticas de check-in, wifi y cotizaciones de habitaciones.
* **Sugerencias Rápidas:** Botones de acción instantánea en la interfaz de chat.

### ⛵ 3. Tours y Experiencias Turísticas
* **Catálogo de Actividades:** Tours en catamarán a cayos y arrecifes, cenas románticas frente al mar y sesiones de spa/masajes.
* **Integración Directa:** Los huéspedes pueden consultar y solicitar experiencias turísticas directamente desde su celular.

### 🛎️ 4. Recepción y Front Desk (Staff / Administrador)
* **Gestión de Reservas:** Aprobación inmediata de solicitudes de reserva pendientes.
* **Check-In con 1 Toque:** Al llegar el huésped, se registra el check-in y la habitación cambia automáticamente a `Ocupada`.
* **Check-Out Automatizado:** Al retirarse el huésped, se liquida la cuenta y la habitación pasa automáticamente a `Requiere Limpieza`.
* **Cargos Extras y Consumos:** Capacidad de agregar consumos de minibar, desayunos o servicios a la cuenta de la habitación.

### 🧹 5. Limpieza y Mantenimiento (*Housekeeping*)
* Control del ciclo de vida de la habitación: `Disponible` ➔ `Ocupada` ➔ `Limpieza` ➔ `Mantenimiento`.
* Actualización rápida de estado por el personal de mantenimiento desde su teléfono móvil.

### ⚙️ 6. Configuración del Hotel y Tasa Cambiaria en Vivo
* Actualización de la **Tasa Oficial del Dólar (BCV)** que recalcula los precios en Bolívares de inmediato en toda la aplicación.
* Edición de información de contacto, WhatsApp de atención y ubicación.

### 📊 7. Dashboard Financiero y Métricas
* **KPIs en Vivo:** Tasa de ocupación porcentual, habitaciones ocupadas vs disponibles, reservas pendientes por aprobar.
* **Gráficos de Ingresos:** Histórico de facturación de los últimos 6 meses usando `fl_chart`.

---

## 3. Estructura del Código (Clean Architecture)

```text
posada/
├── legacy/                        # Respaldo seguro del código PHP/MySQL original (Histórico)
│   ├── index.php
│   ├── posada.sql
│   ├── interfaz/
│   └── nucleo/
│
├── backend/                       # Solución C# .NET 10 Web API (Clean Architecture)
│   ├── Dockerfile                 # Contenedor Multi-stage para Render / Koyeb
│   ├── Posada.slnx
│   └── src/
│       ├── Posada.Domain/         # Entidades (User, Room, Booking, Payment, ExtraCharge, Experience, Review, PromoCode, HotelSetting)
│       ├── Posada.Application/    # DTOs, interfaces de servicios y respuestas estandarizadas
│       ├── Posada.Infrastructure/ # EF Core, PostgreSQL, BCrypt, JWT Generator, Data Seeder
│       └── Posada.API/            # Controladores REST (Auth, Rooms, Bookings, Experiences, Reviews, AI, Dashboard, Settings)
│
├── frontend/                      # Aplicación Flutter Multiplataforma
│   ├── pubspec.yaml
│   └── lib/
│       ├── core/                  # Cliente HTTP Dio con JWT Interceptors, Temas M3, Currency Formatters
│       ├── features/
│       │   ├── auth/              # Login, Registro, Roles (Admin, Receptionist, Guest)
│       │   ├── rooms/             # Catálogo de habitaciones, filtros por tipo, amenidades
│       │   ├── bookings/          # Motor de cotización, selector de fechas, generación de Código QR
│       │   ├── concierge/         # Chat interactivo con Asistente Virtual IA
│       │   ├── experiences/       # Catálogo de tours y actividades
│       │   ├── reception/         # Front Desk, Check-In, Check-Out, cargos por consumos extras
│       │   ├── housekeeping/      # Módulo de limpieza y mantenimiento de habitaciones
│       │   ├── settings/          # Configuración del hotel y tasa cambiaria oficial en tiempo real
│       │   ├── dashboard/         # Dashboard con métricas de ocupación, ingresos y gráficos FLChart
│       │   └── home/              # Navegación responsiva (Sidebar en Web/PC, BottomNav en Móvil)
│       └── main.dart
│
└── DOCUMENTACION.md
```

---

## 4. Usuarios y Credenciales Preconfiguradas (Semilla Automática)

| Rol | Usuario | Correo | Contraseña | Permisos |
|---|---|---|---|---|
| **Administrador** | `admin` | `admin@posada.com` | `Admin12345*` | Acceso total (Dashboard, Recepción, Habitaciones, Limpieza, Concierge IA, Configuración) |
| **Recepcionista** | `recepcion` | `recepcion@posada.com` | `Recepcion123*` | Gestión de reservas, Check-in/out, consumos extras |
| **Huésped (Demo)** | `julimer` | `julimer@gmail.com` | `Cliente123*` | Exploración de catálogo, reservas personales, tours y concierge |

---

## 5. Guía de Despliegue en la Nube (100% Gratis)

### Paso 1: Base de Datos PostgreSQL en Neon.tech
1. Crea tu base de datos gratuita en [Neon.tech](https://neon.tech).
2. Copia tu cadena de conexión PostgreSQL.

### Paso 2: Despliegue del Backend en Render
1. Conecta tu repositorio de GitHub a [Render.com](https://render.com).
2. Crea un **Web Service**, selecciona la carpeta `backend` y el entorno `Docker`.
3. Configura la variable de entorno `ConnectionStrings__DefaultConnection` con la URL de Neon.tech.
4. Render desplegará el contenedor y tendrás tu API y Swagger listos 24/7.

### Paso 3: Frontend Flutter (Web & Móvil)
1. Conecta `frontend/lib/core/api/api_endpoints.dart` a tu URL de Render.
2. Para compilar la versión Web: `flutter build web --release`
3. Para compilar el APK de Android: `flutter build apk --release`

---
*Posada Pro v2.5 - Suite Hotelera Empresarial.*
