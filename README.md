# SportBook

A full-stack sports facility booking system with a REST API backend and a Flutter mobile client. Users browse courts, book available time slots, rent equipment, and check in on-site with a QR code.

## Overview

SportBook solves the practical problem of managing bookings for sports facilities. Instead of phone calls and paper schedules, users see current availability, reserve a slot, and receive a QR code that staff scan at the entrance to verify the reservation.

The system is built around two clients sharing one API: a Flutter mobile app for users and administrators, and an ASP.NET Core backend handling authentication, business rules, and data.

## Architecture

```
┌─────────────────┐                    ┌──────────────────────┐                 ┌────────────┐
│  Flutter App    │   HTTP + JWT       │  ASP.NET Core API    │    EF Core      │ SQL Server │
│  (Dart)         │ ─────────────────► │  Controllers / DTOs  │ ──────────────► │            │
└─────────────────┘                    └──────────────────────┘                 └────────────┘
```

The Flutter client never touches the database directly. All communication goes through the REST API, with a JWT token attached to every authenticated request. DTOs separate the API contract from the internal database models.

## Features

### Authentication & Authorization
- User registration and login
- Passwords hashed with **BCrypt** (never stored in plain text)
- **JWT tokens** issued on login, carrying user ID and role as claims
- **Role-based authorization** — administrator-only endpoints are protected with `[Authorize(Roles = "administrator")]`

### Booking
- Browse sports facilities and courts, filtered by sport
- View available time slots for a given court and date
- Create a reservation, with three server-side checks before it is accepted:
  - the slot must still be marked as free
  - no other active reservation may exist for that slot
  - the slot must not overlap with a court blockade
- View personal reservation history
- Cancel an upcoming reservation, which releases the slot back to availability

### QR Check-in
- A unique QR code is generated for every reservation
- Each code carries an expiry date and is valid for 7 days
- Administrators scan the code with the device camera on arrival
- The backend validates the code and marks it as used — **a used code is rejected on any further scan**

### Equipment Rental
- Equipment can be added to a reservation
- Stock availability is checked before the rental is confirmed
- Rented items are linked to the reservation through a join table

### Reviews & Ratings
- Users can leave a rating and comment for a court after using it
- Average rating per court is calculated and returned with facility data

### Administration
- View all reservations across the system
- Scan reservation QR codes for check-in
- Generate time slots automatically from a court's defined working hours
- Block a court for a time range (maintenance, private events); blocked periods are then checked against every new booking attempt

## Technical Decisions

- **Client–server separation** — the Flutter app communicates exclusively through the REST API and has no direct database access, so the same backend can serve additional clients without changes.
- **DTOs** — request and response objects keep the API contract independent from the internal database entities.
- **JWT over sessions** — stateless authentication suits a mobile client, and role claims travel with the token so authorization can be enforced per endpoint.
- **EF Core migrations** — the database schema is versioned with the code, so a fresh environment can be created with a single command.
- **Server-side validation** — booking rules are enforced in the API rather than the client, so they hold regardless of which client calls the endpoint.

## Tech Stack

**Backend**
- ASP.NET Core 8 (C#)
- Entity Framework Core
- SQL Server
- JWT Bearer authentication
- BCrypt.Net for password hashing

**Mobile Client**
- Flutter / Dart
- `http` — REST API communication
- `shared_preferences` — local session and token storage
- `qr_flutter` — QR code generation
- `mobile_scanner` — camera-based QR scanning
- `intl` — date and time formatting

## Project Structure

```
sportbook/
├── SportBookapp/SportBook/SportBook.API/
│   ├── Controllers/          # API controllers
│   ├── Models/               # Database entities
│   ├── DTOs/                 # Request/response objects
│   ├── Migrations/           # EF Core database migrations
│   ├── data/                 # DbContext and Fluent API configuration
│   └── Program.cs            # Service registration, JWT setup, CORS
└── sportbook_app/
    └── lib/
        ├── screens/          # UI screens
        └── services/         # API service layer
```

## Database

Relationships are configured through EF Core's Fluent API:

- **One-to-one** — a reservation has exactly one QR code, and at most one review
- **One-to-many** — a facility has many courts; a court has many time slots and working hours
- **Many-to-many** — courts to sports, and reservations to equipment, both through join tables

Delete behaviour is set per relationship. Deleting a reservation cascades to its equipment entries, while the equipment side uses `Restrict` so that removing an item from the catalogue cannot erase historical reservation records.

## API Endpoints

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | — | Register a new user |
| POST | `/api/auth/login` | — | Log in, receive JWT |
| GET | `/api/court` | — | List all courts |
| GET | `/api/court/{id}` | — | Court details with average rating |
| GET | `/api/court/sports` | — | List available sports |
| GET | `/api/timeslot/{courtId}/{date}` | — | Available slots for a court and date |
| POST | `/api/timeslot/generate` | Admin | Generate slots from working hours |
| POST | `/api/reservation` | User | Create a reservation |
| GET | `/api/reservation/user/{id}` | User | User's reservations |
| PUT | `/api/reservation/{id}/cancel` | User | Cancel a reservation |
| GET | `/api/equipment` | — | List available equipment |
| POST | `/api/equipment/add` | — | Add equipment to a reservation |
| POST | `/api/review` | User | Leave a review |
| GET | `/api/review/court/{id}` | — | Reviews for a court |
| GET | `/api/admin/reservations` | Admin | All reservations |
| POST | `/api/admin/scan` | Admin | Validate a QR code |
| POST | `/api/admin/block` | Admin | Block a court for a time range |

## Setup

### Backend

1. Navigate to the API project:
   ```
   cd SportBookapp/SportBook/SportBook.API
   ```
2. In `appsettings.json`, set your SQL Server connection string and a JWT signing key (minimum 32 characters).
3. Create the database:
   ```
   dotnet ef database update
   ```
4. Run the API:
   ```
   dotnet run
   ```

### Mobile App

1. Navigate to the app folder:
   ```
   cd sportbook_app
   ```
2. Install dependencies:
   ```
   flutter pub get
   ```
3. In `lib/services/api_service.dart`, set `baseUrl` to your running API address.
4. Run the app:
   ```
   flutter run
   ```

## Possible Extensions

- Full CRUD for facilities, courts, and the equipment catalogue from the admin panel
- User management for administrators
- Payment integration
- Push notifications for upcoming reservations
- A web client sharing the same API

## Author

**Jusuf Dacic**
Faculty of Traffic and Communications, University of Sarajevo
[github.com/Jusufdacic](https://github.com/Jusufdacic)
