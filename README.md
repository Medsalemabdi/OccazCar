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
## 3. Configuration (Crucial Step)
Firebase Configuration with FlutterFire CLI

1.Prerequisites
Install the Firebase CLI:
```bash
npm install -g firebase-tools
````
Log in to Firebase:
```bash
firebase login

````
Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli

````
2. Project Configuration
From the root of your Flutter project:
```bash
flutterfire configure
```
→ Generates lib/firebase_options.dart and automatically configures Firebase for the selected platforms.

3. Add Flutter Dependencies

```bash

flutter pub add firebase_core
flutter pub get
````

This project requires API keys and configuration files to function correctly.

### a) Firebase (Android)
1. Download your `google-services.json` file from your Firebase project console.
2. Place it in:
   - `android/app/google-services.json`

### b) Firestore Security Rules

Add the following rules in **Firebase Console → Firestore Database → Rules**:

```js
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // --- ADS ---
    match /ads/{adId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.sellerId;
    }

    // --- USERS ---
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // --- CONVERSATIONS ---
    match /conversations/{conversationId} {
      // 1) CREATE
      allow create: if request.auth != null && (
        request.resource.data.buyerId == request.auth.uid ||
        request.resource.data.sellerId == request.auth.uid
      );

      // 2) READ
      allow read: if request.auth != null && (
        resource.data.buyerId == request.auth.uid ||
        resource.data.sellerId == request.auth.uid ||
        resource.data.participants.hasAny([request.auth.uid])
      );

      // 3) UPDATE
      allow update: if request.auth != null && (
        resource.data.buyerId == request.auth.uid ||
        resource.data.sellerId == request.auth.uid ||
        resource.data.participants.hasAny([request.auth.uid])
      );

      // MESSAGES (subcollection)
      match /messages/{messageId} {
        allow read, write: if request.auth != null && (
          get(/databases/$(database)/documents/conversations/$(conversationId)).data.buyerId == request.auth.uid ||
          get(/databases/$(database)/documents/conversations/$(conversationId)).data.sellerId == request.auth.uid
        );
      }
    }

    // --- ALERTS ---
    match /alerts/{alertId} {
      // Allow creation only if the user is logged in AND the alert belongs to them
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;

      // Allow reading and deleting only their own alerts
      allow read, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }

  }
}


```
### c) API Keys (Hugging Face)
b. Hugging Face API Key
The Hugging Face API key is required for the AI-powered ad description generator.

1.Open the file: lib/features/ia/ai_service.dart

2.Find the _apiKey variable inside the AIService class.

3.Replace the placeholder ********************** with your actual Hugging Face Read Token.

### d) Cloudinary Credentials
The Cloudinary Cloud Name and Upload Preset are managed directly in the service file.

1. Open:
   - `lib/features/seller/services/ad_service.dart`
2. Find the `CloudinaryPublic` instance and replace the placeholders:

```dart
final cloudinary = CloudinaryPublic(
  'YOUR_CLOUDINARY_CLOUD_NAME',
  'YOUR_CLOUDINARY_UPLOAD_PRESET', // Must be an "Unsigned" preset
  cache: false,
);

````
4.Add fingerprints to firebase
```bash
cd android
gradlew singingReport

Copy sha256 and sha1 fingerprints and add them to app fingerprints in firebase
5. Run the App
```bash
flutter run
````
