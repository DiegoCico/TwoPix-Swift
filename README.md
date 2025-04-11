# 📸 TwoPix – A Private Photo Messaging App for Two

## 🧠 Project Overview

**TwoPix** is a gesture-driven, minimalist photo messaging app made for exactly **two users**. It creates a private space for sharing photos and messages — think Snapchat, but stripped down to just *you and your person*. No feeds, no distractions, just connection.

Built with `SwiftUI`, `AVFoundation`, and `Firebase`, the app offers a custom camera experience, real-time chat, and an intuitive swipe-to-send UI. Firebase handles user authentication, image uploads, chat data, and cloud functions.

---

## 🔑 Key Features

- **Authentication**
  - Email/password login using Firebase Auth
- **Pix Code Connection**
  - 6-digit code to securely pair two accounts into one private space
- **Camera View**
  - Pinch-to-zoom
  - Double-tap to flip front/back
  - Flash toggle (including front flash simulation)
  - Real-time camera preview with image capture
- **Photo Preview Overlay**
  - Swipe **right** to send
  - Swipe **left** to discard
  - Double-tap to save image to device
- **Chat System**
  - Firestore-based real-time chat
  - Supports text + tagged images ("Normal", "FitCheck", "Spicy")
  - Full-screen photo viewing with pinch, pan, and swipe-to-dismiss
  - Auto scroll-to-bottom + seen-status tracking
- **Photo Uploader**
  - JPEG compression
  - Firebase Storage upload
  - Firestore metadata handling

---

## ☁️ Firebase Cloud Functions

Two scheduled background tasks:

- `deleteOldChatMessages`: Deletes chats older than 7 days
- `deleteOldPhotos`: Cleans up photos and metadata after 30 days

Located in `functions/index.ts`.

---

## 🚧 Current Limitations

- No push notifications (yet)
- No video message support
- No in-app profile editing

---

## 🛠️ Planned Improvements

| Area             | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| 💬 Chat UI/UX    | Smoother input, typing indicators, media layout enhancements                |
| 📷 Camera Bugs    | Fix intermittent bugs and UI glitches for smoother capture and transitions |
| 📹 Video Support  | Add support for recording and sending short video clips                     |
| 🧭 Navigation UX  | More fluid transitions and onboarding improvements                          |
| ⚡ Performance    | Optimize Firebase calls and local state management                          |

---

## 🧪 Tech Stack

- `SwiftUI`
- `AVFoundation`
- `Firebase Auth`
- `Firebase Firestore`
- `Firebase Storage`
- `Firebase Functions (TypeScript)`

---

## 📲 Screenshots *(Coming Soon)*

Planned showcase of:
- Auth screen with animated background
- Pix Code generation and connection
- Camera preview + swipe-based photo preview
- Chat view + full-screen image viewer

---

## 🔒 License

This project is licensed under the [Apache License 2.0](./LICENSE).

> ❗ **Note:** Reusing UI/UX, flows, or branding without permission is not allowed. Code snippets may be reused in accordance with the license, but cloning or redistributing the full app is strictly prohibited.
