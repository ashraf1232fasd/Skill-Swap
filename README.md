
<div align="center">

<img src="https://img.icons8.com/fluency/96/null/time-machine.png" alt="Logo" width="100" height="100">

# ⏳ Skill Swap
### The Future of Skill Exchange | Time Banking Ecosystem

<p>
  <a href="#-system-architecture">Architecture</a> •
  <a href="#-key-features">Features</a> •
  <a href="#-getting-started">Getting Started</a> •
  <a href="#-api-documentation">API Docs</a>
</p>

![Flutter](https://img.shields.io/badge/Flutter-3.x-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![NodeJS](https://img.shields.io/badge/Node.js-18-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Socket.io](https://img.shields.io/badge/Socket.io-RealTime-black?style=for-the-badge&logo=socket.io&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-6.0-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)
![Express](https://img.shields.io/badge/Express.js-4.x-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB)

</div>

---

## 🚀 Overview

**Skill Swap** is a revolutionary platform redefining the gig economy through **Time Banking**. It eliminates currency, allowing users to trade skills based purely on time duration.

The platform is a robust **Full-Stack Application** featuring complex scheduling algorithms, atomic transactions for time-credits, and a **Real-time Chat System** for seamless negotiation.

> **Core Philosophy:** *One hour of coding equals one hour of cooking. Time is the only currency.*

---

## ✨ Key Features

### 🔄 The Economy
* **Time-Banking Wallet:** Automated deduction and refund logic based on service duration.
* **Frozen Balance:** "Escrow-like" system where time credits are held until service completion to prevent fraud.

### 💬 Real-Time Communication (New)
* **Instant Messaging:** Built with **Socket.io** for sub-millisecond latency.
* **Live Updates:** Messages appear instantly without refreshing.
* **Chat History:** Persistent storage of conversations in MongoDB.
* **Smart Indicators:** Real-time timestamps and read status.

### 📅 Scheduling & Discovery
* **Conflict Detection:** Prevents double-booking for both students and teachers.
* **Dual-Role Toggle:** Switch between "Teacher" (Offer) and "Student" (Request) modes instantly.
* **Advanced Filtering:** Search by category, keyword, or service type.

---

## 🏗 System Architecture

The project follows a **Client-Server Architecture** separating the presentation layer (Mobile) from the business logic layer (API).

### 🔌 Real-Time Architecture (WebSocket)
We utilize **Socket.io** to establish a bidirectional event-based communication channel:
1.  **Connection:** User connects and joins a private `Room` based on their User ID.
2.  **Events:**
    * `setup`: Initialize user connection.
    * `join chat`: Enter a specific conversation room.
    * `new message`: Broadcast message to the recipient's room.

### 📂 Database Schema (MongoDB)

| Collection | Description | Key Relationships |
| :--- | :--- | :--- |
| **Users** | Profile, Wallet (`timeBalance`, `frozenBalance`). | `hasMany` Services, Bookings, Chats |
| **Services** | Offers/Requests posted by users. | `belongsTo` User (Provider) |
| **Bookings** | Transaction entity handling status logic. | `belongsTo` Student, Provider, Service |
| **Chats** | **(New)** Groups two users in a conversation. | `hasMany` Messages, `ref` Users |
| **Messages** | **(New)** Individual text payloads. | `belongsTo` Chat, `belongsTo` Sender |

---

## 🛠 Engineering Highlights

### 1. The "Time-Lock" Algorithm
To ensure fairness, the system implements a robust transaction flow:
* **Booking:** Time deducted from `Available` -> Moved to `Frozen`.
* **Completion:** `Frozen` burned -> Provider receives credit.
* **Cancellation:** `Frozen` refunded instantly.

### 2. Socket.io Integration
Unlike traditional REST polling, our chat system pushes data instantly. The Flutter client uses `Provider` to listen to socket streams and update the UI state efficiently, handling connection drops and reconnections gracefully.

---

## 📂 Project Structure

Organized for scalability, separating Chat logic from core Booking logic.

```bash
Skill-Swap/
├── backend/                  # Node.js Server
│   ├── config/               # DB & Socket Setup
│   ├── controllers/          # Business Logic (Auth, Booking, Chat)
│   ├── models/               # Schemas (User, Service, Chat, Message)
│   ├── routes/               # API Endpoints
│   └── middleware/           # Auth & Error Handling
│
└── lib/                      # Flutter App
    ├── core/                 # Constants, Themes, Utils
    ├── data/                 # API Services (Dio Client)
    ├── providers/            # State Management
    │   ├── auth_provider.dart
    │   ├── chat_provider.dart  <-- New Socket Logic
    │   └── ...
    ├── screens/              # UI Screens
    │   ├── chat/             <-- New Chat UI
    │   └── ...
    └── widgets/              # Reusable Components

```

---

## ⚡ Getting Started

### Prerequisites

* Flutter SDK (3.0+)
* Node.js (v16+)
* MongoDB (Local or Atlas)

### 1. Backend Setup

Navigate to the backend directory:

```bash
cd backend
npm install

```

*Make sure to install `socket.io` if not already installed.*

Create a `.env` file:

```env
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key

```

Start the server:

```bash
npm start

```

### 2. Mobile App Setup

Navigate to the root directory:

```bash
flutter pub get
flutter run

```

---

## 🔌 API Documentation

| Method | Endpoint | Access | Description |
| --- | --- | --- | --- |
| `POST` | `/api/auth/register` | Public | Register new user + 60 min bonus |
| `POST` | `/api/bookings` | Private | Create booking (Atomic Transaction) |
| `POST` | `/api/chat` | Private | **Access or create a one-on-one chat** |
| `GET` | `/api/chat` | Private | **Fetch all user conversations** |
| `POST` | `/api/chat/message` | Private | **Send a message (Trigger Socket)** |
| `GET` | `/api/chat/message/:id` | Private | **Get message history** |

---

<div align="center">

**Developed by Ashraf**

Full Stack Developer (Flutter & Node.js)

[GitHub Profile](https://github.com/)

</div>

```

```
