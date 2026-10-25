# SportBook

A full-stack sports facility booking system with a REST API backend and a Flutter client. Users browse courts, book available time slots, rent equipment, and check in on-site with a QR code.

## Author & Owner

**Quang Hoang Minh** ([@dsaPhobic](https://github.com/dsaPhobic))  
Email: [hmquang9805@gmail.com](mailto:hmquang9805@gmail.com)  
Repository: [https://github.com/dsaPhobic/sportbook](https://github.com/dsaPhobic/sportbook)

---

## Overview

SportBook solves the practical problem of managing bookings for sports facilities. Instead of phone calls and paper schedules, users see current availability, reserve a slot, and receive a QR code that staff scan at the entrance to verify the reservation.

The system is built around two components sharing one API: a Flutter client (Mobile & Web) for users and administrators, and an ASP.NET Core (.NET 8) backend handling authentication, business rules, and data persistence.

## Architecture

```
┌─────────────────┐                    ┌──────────────────────┐                 ┌────────────┐
│  Flutter App    │   HTTP + JWT       │  ASP.NET Core API    │    EF Core      │ SQL Server │
│  (Dart/Web/App) │ ─────────────────► │  Controllers / DTOs  │ ──────────────► │            │
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
- Create a reservation with strict validation checks before acceptance:
  - The slot must still be marked as free
  - No other active reservation may exist for that slot
  - The slot must not overlap with a court block
- View personal reservation history
- Cancel upcoming reservations, releasing the slot back to availability

### QR Check-in
- A unique QR code is generated for every reservation
- Each code carries an expiry date and is valid for 7 days
- Administrators scan the code or enter the code string on arrival
- The backend validates the code and marks it as used — **a used code is rejected on any further scan**

### Equipment Rental
- Equipment (balls, rackets, bibs, protective gear) can be rented alongside a reservation
- Stock availability is verified before the rental is confirmed
- Rented items are linked to the reservation through join tables

### Reviews & Ratings
- Users can leave a rating (1-5 stars) and comment for a court after using it
- Average rating per court is calculated and returned with facility data

### Administration
- Comprehensive Admin Dashboard for facility and booking management
- Scan / verify reservation QR codes for check-in
- Manage courts, sports, and equipment catalog
- Block courts for maintenance or private events

## Tech Stack

**Backend**
- ASP.NET Core 8 (C#)
- Entity Framework Core 8
- Microsoft SQL Server
- JWT Bearer Authentication
- BCrypt.Net-Next

**Client**
- Flutter 3 (Web, Android, iOS, Windows, macOS, Linux)
- `http` — REST API communication
- `shared_preferences` — local session and token storage
- `qr_flutter` — QR code generation
- `mobile_scanner` — camera-based QR scanning
- `intl` — date and time formatting

## Project Structure

```
sportbook/
├── SportBookapp/SportBook/SportBook.API/
│   ├── Controllers/          # API controllers (Court, Auth, Admin, etc.)
│   ├── Models/               # Domain entities
│   ├── DTOs/                 # Request/response data transfer objects
│   ├── Migrations/           # EF Core database migrations
│   ├── data/                 # DbContext and Fluent API configuration
│   └── Program.cs            # Service registration, JWT setup, CORS
├── sportbook_app/
│   └── lib/
│       ├── screens/          # UI screens (Home, Courts, Booking, QR, Admin)
│       └── services/         # API service layer
├── seed_data.sql             # SQL script seeding 50 records per table
└── generate_seed.py          # Python seed generator utility
```

---

## Setup & Running Guide

### 1. Database Setup & EF Core Migration

1. Ensure **Microsoft SQL Server** is running locally (e.g., `localhost` or `SQLEXPRESS`).
2. Verify the connection string in `SportBookapp/SportBook/SportBook.API/appsettings.json`:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=localhost;Database=SportBook;Trusted_Connection=True;TrustServerCertificate=True;"
   },
   "Jwt": {
     "Key": "SportBookSecretKey_2026_SecureJwtAuthToken_Min32Chars!"
   }
   ```
3. Open terminal in the API project folder:
   ```bash
   cd SportBookapp/SportBook/SportBook.API
   ```
4. Apply the EF Core database migrations to create the database schema:
   ```bash
   dotnet ef database update
   ```

### 2. Seed Sample Data (50 Records per Table)

The repository includes a ready-to-use seed script `seed_data.sql` that populates **50 realistic records** for all 15 tables with valid BCrypt password hashes and proper foreign key relationships.

Run the seed script using `sqlcmd` from the root directory:
```bash
sqlcmd -S localhost -d SportBook -E -i seed_data.sql
```

*(Alternatively, you can open `seed_data.sql` in SQL Server Management Studio (SSMS) or Azure Data Studio and execute it).*

#### Default Accounts (Ready to Test):
- **Admin Account:**
  - Email: `admin@sportbook.local`
  - Password: `Password123!`
  - Role: `administrator` (Opens Admin Panel)
- **Client Account:**
  - Email: `user12.kevin@sportbook.local` (or `user21.tina@sportbook.local`, `user43.evelyn@sportbook.local`)
  - Password: `Password123!`
  - Role: `client` (Opens User booking flow)

### 3. Run Backend API

From `SportBookapp/SportBook/SportBook.API`:
```bash
dotnet run --launch-profile http
```
- API will start at: `http://localhost:5029`
- Swagger API documentation: `http://localhost:5029/swagger`

### 4. Run Frontend (Flutter)

1. Open a new terminal in the `sportbook_app` folder:
   ```bash
   cd sportbook_app
   ```
2. Install packages:
   ```bash
   flutter pub get
   ```
3. Run on Chrome / Web:
   ```bash
   flutter run -d chrome --web-port=8080
   ```
   *(Or run on Edge / Windows / Mobile emulator)*
4. Open your browser at `http://localhost:8080` to start exploring the application.

---

## License

This project is open-source under the MIT License.
