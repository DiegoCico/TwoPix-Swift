# 📸 TwoPix – A Private Photo Messaging App for Two

**TwoPix** is a secure, intimate photo messaging app designed exclusively for *two people*. Think Snapchat, but tailor-made for just you and your favorite person. No distractions, no feeds — just private, meaningful connection.

> ⚠️ **Note:** This project is currently under active development. Expect updates, improvements, and occasional changes as we build toward v1.0.

---

## 🔥 Features

- 🌀 **Animated Background** – A playful, visually dynamic UI with smooth animated effects.
- 🔐 **Secure Firebase Authentication** – Email/password login support.
- 🔗 **Pix Code System** – A unique 6-digit code that connects two users for private messaging.
- 📸 **Integrated Camera Support** – Front/back cameras with flash, pinch-to-zoom, and double-tap flip.
- 😤️ **Chat System** – Real-time messaging powered by Firestore, including text and photos.
- 🖼️ **Photo Previews** – Swipe left to send, swipe right to cancel, view full-screen media with gestures.
- ☁️ **Firebase Firestore & Storage** – All media, metadata, and chat content stored securely in the cloud.
- 🧠 **Smart UX** – Smooth transitions, permission handling, and responsive feedback throughout.

---

## 🗂 Project Structure

```
TwoPix/
├── App/                    // Entry point and main scene
├── Authentication/         // Login, Sign-up, and AuthManager
├── Camera/                 // Camera setup and live preview
├── Chat/                   // Message list, chat bubbles, full-screen viewer
├── PixCode/                // PixCode generation and submission logic
├── Profile/                // Basic user profile view
├── UI/                     // Animated UI elements
├── Firebase Functions/     // Scheduled deletions for old messages & media
```

---

## 🚀 Firebase Cloud Functions

Two scheduled background jobs:
- 🢹 `deleteOldChatMessages`: Cleans up messages older than 7 days.
- 🛋️ `deleteOldPhotos`: Removes images from Storage + Firestore older than 30 days.

These are located in `functions/index.ts`.

---

## 📷 FirebasePhotoUploader

Handles:
- Image compression
- Firebase Storage upload
- Firestore metadata creation
- Photo tag support (`FitCheck`, `Normal`, `Spicy`)

Returns download URL upon success and integrates directly with the chat system.

---

## 💬 Chat System

Supports:
- Text and image messages
- Real-time updates using `.addSnapshotListener`
- Full-screen image preview with drag-to-dismiss
- Intelligent UI layout for current vs. partner messages

---

## ⟳ Pix Code System

- Users generate or submit a **6-digit Pix Code** to link accounts.
- Firestore tracks connection state under the `pixcodes` and `users` collections.
- One code = one connection = one private channel.

---

## 🚣️ Roadmap

- [ ] 🎨 Refine UI/UX animations and transitions
- [ ] 🔔 Add push notifications (Firebase Messaging)
- [ ] 📹 Support for video messages
- [ ] 🔐 Enhance encryption & message security
- [ ] 🌐 Optimize for broader device compatibility
- [ ] 🎨 Add customizable themes and personalization

---

## 🧪 Tech Stack

- `SwiftUI`
- `Firebase Auth`
- `Firebase Firestore`
- `Firebase Storage`
- `Firebase Functions (TypeScript)`
- `AVFoundation` for camera integration

---

## 📌 Coming Soon

- Photo expiration logic (based on metadata)
- Better onboarding UI
- App icon + launch screen
- In-app profile editing

---

## 📲 Screenshots (coming soon)

> Planning to showcase the animated UI, Pix Code screen, and swipe-to-send preview overlay.

