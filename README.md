# 📱 Mobile Test Application

A full-stack mobile application built with **Flutter**, **Node.js**, and **SQL Server**.  
This project demonstrates authentication, category & product management, image upload, pagination, sorting, and Khmer language support.

---

## 🧱 Tech Stack

### Frontend
- Flutter
- Riverpod (State Management)
- CachedNetworkImage
- Image Picker

### Backend
- Node.js
- Express.js
- SQL Server
- JWT Authentication
- Multer (Image Upload)

### Database
- Microsoft SQL Server

---

## 🚀 Setup & Run Instructions

---

### 1️⃣ Database Setup (SQL Server)

1. Open **SQL Server Management Studio**
2. Run the following SQL file:
sql/schema.sql

This will create:
- Database: `mobile_test_db`
- Tables: `users`, `categories`, `products`

---

### 2️⃣ Backend Setup (Node.js)

```bash
cd backend
npm install
Create a .env file
PORT=3000
JWT_SECRET=your_jwt_secret

DB_HOST=localhost
DB_NAME=mobile_test_db
DB_USER=your_db_user
DB_PASSWORD=your_db_password

EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_app_password
Run the backend:
npm run dev
```
3️⃣ Frontend Setup (Flutter)
cd frontend/frontend_tonair_test
flutter pub get
flutter run
🌐 API Base URL
| Environment      | Base URL                    |
| ---------------- | --------------------------- |
| Local            | `http://localhost:3000/api` |
| Android Emulator | `http://10.0.2.2:3000/api`  |

---

📌 Key Features

Authentication (Login / Signup / Reset Password)

Category CRUD (Khmer & English supported)

Product CRUD

Product image upload (local storage)

Pagination (20 items per page)

Infinite scrolling

Sorting (Name / Price)

Debounced search

Category filtering

Image placeholders & fallback handling
