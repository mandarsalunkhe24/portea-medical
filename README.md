# Portea Medical – Home Healthcare App

Cross-platform Flutter app for booking home healthcare services: nurse visits, physiotherapy, medical equipment rental and elderly care, with verified professionals and service tracking.

**Project 123 – B.Tech Computer Science Engineering & AI (Cross Platform Application), ITM Skills University**

---

## 🔗 Project Links

### 🌐 Live Web App
[Launch Portea Medical in Browser](https://porteahealthcare-217c9.web.app)

### 📱 Download the App (Android APK)
[Download from GitHub Releases](https://github.com/mandarsalunkhe24/portea-medical/releases/latest)

### 💻 GitHub Repository
https://github.com/mandarsalunkhe24/portea-medical

### 🎨 Figma Design
https://www.figma.com/design/duR9muCYDsnefN90YRGyKQ

---

## ✨ Features

| Feature from the brief | Where in the app |
|---|---|
| Service categories (nurse, physiotherapy, equipment rental, elderly care) | Home dashboard |
| Professional selection with photo, qualifications, languages | Professionals list and profile |
| Professional verification (ID proof, certifications) | Verified Documents section on profile |
| Time slot calendar with availability and booking | Booking calendar, My Bookings |
| Care plan with recurring visit schedule | Care Plan creator and Care Plans tab |
| Service completion with photo evidence | Service Completion screen |
| Emergency contacts and SOS button | SOS screen and floating SOS button |
| Equipment rental catalog with monthly rates | Equipment catalog, detail and My Rentals |
| Medical equipment delivery tracking | Delivery Tracking screen |
| Elderly care package with daily visit schedule | Elderly Care package |
| Patient reviews with ratings and feedback | Write Review and reviews list |
| Insurance claim assistance | Insurance Assistance and Claim Request |
| Email/password authentication | Firebase Authentication |

## 💰 Pricing Logic

| Item | Price |
|---|---|
| Nurse visit | ₹599 per visit |
| Physiotherapy | ₹799 per visit |
| Care package | 10 visits at 15% discount (Nurse ₹5,091.50, Physio ₹6,791.50) |
| Monthly elderly care | ₹8,999 for daily visits |
| Equipment rental | Monthly rental starting ₹499 |

The discount is applied automatically when a care plan has 10 or more visits. All prices live in `lib/core/pricing.dart`.

## 🛠 Tech Stack

- Flutter (Material 3), Dart
- State management: Provider
- Authentication: Firebase Authentication (email/password)
- Local storage: shared_preferences
- Packages: table_calendar, intl, image_picker, flutter_rating_bar, url_launcher, google_fonts, cached_network_image, uuid

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── core/          theme, constants, pricing, utils
├── data/          mock_data.dart
├── models/        booking, care plan, equipment, professional, review, ...
├── providers/     auth, booking, care plan, equipment, emergency, insurance, ...
├── screens/       auth, home, professionals, booking, care_plan, equipment, sos, ...
└── widgets/       reusable widgets
```

## 🚀 Run Locally

```bash
git clone https://github.com/mandarsalunkhe24/portea-medical.git
cd portea-medical
flutter pub get
flutter run -d chrome
```

Run tests: `flutter test`

### Firebase setup
1. Create a Firebase project and enable **Authentication → Email/Password**.
2. Run `flutterfire configure` to generate `lib/firebase_options.dart`.

## 📦 Build

```bash
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
flutter build web --release     # build/web
```

## 🔮 Future Scope

- Real backend (Firestore) for bookings, reviews and professionals
- Online payments and invoices
- Push notifications for visit reminders
- Live location tracking for professionals and deliveries

## 👤 Author

Mandar Salunkhe – B.Tech CSE & AI, ITM Skills University
