# 🚗 OccazCar

> The modern marketplace for buying and selling used vehicles, powered by AI.

## 📖 Introduction

**OccazCar** is a native mobile application (Android) built with Flutter. It aims to streamline the used car market by solving two major pain points: the complexity of creating listings for sellers and the lack of trust for buyers.

The application stands out through its **Serverless Architecture**, strict **Role Segregation**, and the integration of **Artificial Intelligence** to assist users.

---

## ✨ Key Features

### 🔐 Core & Authentication
* **Secure Sign Up/Login** via Firebase Auth (Email/Password).
* **RoleGate:** Immutable role assignment (`buyer` or `seller`) with dynamic routing to the appropriate interface upon login.

### 👨‍💼 Seller Module
* **Dashboard:** Centralized view of all sales activities.
* **Ad Creation:** Comprehensive multi-step form (Brand, Model, Damage Report, etc.).
* **🤖 Smart Drafting (AI):** Automatic generation of persuasive marketing descriptions using the **Dolphin-Mistral-24B** model (via Hugging Face).
* **Media Management:** Multi-image upload hosted on **Cloudinary**.
* **Ad CRUD:** Full management of listings (Edit, Delete with database cleanup).
* **Messaging:** Real-time chat to negotiate and reply to offers.

### 👤 Buyer Module
* **Discovery:** Fluid navigation via interactive ad cards.
* **Search & Filters:** Advanced filtering by Brand, Price, and Year.
* **🔔 Smart Alerts:** Push notifications when a new listing matches saved criteria.
* **Negotiation:** Integrated secure chat to contact sellers.

---

## 🛠 Technical Architecture

The app is built on a **Client-Serverless** architecture implementing the **MVCS** (Model - View - Controller/Service) pattern.

### Tech Stack
| Category | Technology | Details |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | Native Mobile App |
| **Backend (BaaS)** | Firebase | Auth & Firestore |
| **Storage** | Cloudinary | Image CDN |
| **Artificial Intelligence** | Hugging Face API | Model: `dphn/Dolphin-Mistral-24B-Venice-Edition` 

### Logical Architecture (MVCS)
* **Model:** Data structure definitions (Firestore Maps).
* **View:** Passive Flutter Widgets (Screens, Cards, Forms).
* **Service:** Business logic layer bridging UI and APIs (e.g., `AdService`, `AIService`).

---
## 🚀 Installation & Setup

To run this project locally:

### 1. Clone the Repository
```bash
git clone [https://github.com/your-username/OccazCar.git](https://github.com/your-username/OccazCar.git)
cd OccazCar
````
### 2. Install Dependencies
```bash
flutter pub get
````


