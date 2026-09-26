# MediTrack Mobile: Patient & Caregiver App

A Flutter companion app for **MediTrack**, a medication adherence monitoring system. This app gives patients and caregivers on-the-go access to dose tracking and adherence history, backed by the same IoT hardware and Flask API that power the MediTrack web dashboards.


---

## Why this app

Patients and caregivers don't always have access to a desktop when it matters: a missed dose, a quick adherence check, or a caregiver checking in on a loved one is often a mobile moment. This app brings the patient and caregiver sides of MediTrack into a native mobile experience, so adherence tracking isn't tied to a web dashboard.

## What it does

The app supports two of MediTrack's three roles:

- **Patient**: views their medication schedule, logs doses, and sees their adherence history
- **Caregiver**: monitors one or more linked patients, reviews adherence trends, and receives alerts on missed doses

Dose data originates from an ESP8266-based hardware unit (reed switch + load cell) and is served to the app through the shared MediTrack Flask REST API. The app itself is a pure client and holds no hardware logic.

*(Doctor role is not included in this app; it's served by the MediTrack web dashboard only.)*

## Features

- Role-based login for patient and caregiver accounts
- Medication schedule view and dose logging
- Add and edit medications, synced in real time across the mobile app and web dashboards
- Push notifications for missed or upcoming doses
- Adherence history and trend visualisation
- Caregiver-to-patient linked monitoring, with multiple patients per caregiver
- Syncs with live or seeded demo data via the MediTrack backend API

## Tech stack

| Layer | Technology |
|---|---|
| Mobile framework | Flutter (Dart) |
| Backend (consumed) | Python Flask REST API |
| Data source | PostgreSQL (via backend) |

> This app is a client for the main [MediTrack backend](#) and does not run standalone without the Flask API.

## Getting started

### Prerequisites

- Flutter SDK (stable channel)
- A running instance of the MediTrack Flask backend and PostgreSQL database (see the main MediTrack repo)
- Android Studio / Xcode, or an emulator/simulator, for running the app

### Setup

```bash
git clone https://github.com/<your-username>/meditrack-mobile.git
cd meditrack-mobile
flutter pub get
```

Point the app at your backend by setting the API base URL (e.g. in a config/env file):

```dart
const String apiBaseUrl = 'http://<your-backend-host>:5000/api';
```

Then run:

```bash
flutter run
```

## Demo access

The app can be explored using MediTrack's seeded demo accounts:

| Role | Email | Password |
|---|---|---|
| Patient | patient@meditrack.demo | demo1234 |
| Caregiver | caregiver@meditrack.demo | demo1234 |

## What I'd build next

- Offline caching of schedule/adherence data
- Biometric login
- Automated widget/integration tests for the Flutter app

## Author

**Kowthar Abdiqadir**
[LinkedIn](https://www.linkedin.com/in/kowthar-abdiqadir/) · kowthar.abdiqadir@outlook.com
