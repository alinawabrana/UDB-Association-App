# Palm Vein, NFC & QR Based Payment System
## Flutter + Native Android (Kotlin) Implementation Guide

---

## 1. Project Overview

This project implements a **biometric-enabled digital payment system** using:

- Palm Vein Recognition
- NFC Card Reading
- QR Code Scanning

The system is designed for **Leshun LSP980 hardware** and uses a **Flutter + Native Android architecture** to ensure performance, security, and scalability.

---

## 2. High-Level Architecture

Flutter App (Dart)
│
├── UI & User Flow
├── Payment Logic
├── Backend API Integration
│
└── Platform Channels
│
▼
Android Native (Kotlin)
│
├── Palm Vein SDK (ShunPalm)
├── Leshun Hardware SDK
│ ├── NFC
│ ├── QR (Serial Port)
│ ├── Printer
│ ├── System & LED
│
└── Hardware Device

---

## 3. Technology Stack

| Layer | Technology |
|------|-----------|
| Mobile App | Flutter |
| Native Integration | Kotlin |
| Palm Vein SDK | ShunPalm (AAR) |
| Hardware SDK | Leshun HWAdapter |
| Backend | REST API (Client-provided or Custom) |
| Device OS | Android |

---

## 4. Flutter App Responsibilities

Flutter is responsible for:

- User Interface (Customer & Cashier)
- Application workflows
- Communication with backend APIs
- Calling native hardware functions via Platform Channels

Flutter **does not** directly access hardware devices.

---

## 5. Flutter App Modules

### 5.1 UI Screens

#### Customer App
- Splash & Device Check
- Customer Registration
- Palm Vein Enrollment
- Payment Confirmation
- Transaction History

#### Cashier / POS App
- Cashier Login
- Enter Payment Amount
- Select Payment Method
- Payment Status Screen
- Receipt Preview

---

### 5.2 Services Layer

lib/
├── services/
│ ├── hardware_service.dart
│ ├── palm_vein_service.dart
│ ├── payment_service.dart
│ └── printer_service.dart

---

## 6. Flutter ↔ Native Communication

Flutter communicates with native Android using **Method Channels**.

### Channel Name
leshun_hardware_channel

### Example (Flutter)
```dart
static const MethodChannel channel =
    MethodChannel('leshun_hardware_channel');
7. Palm Vein Implementation (Native Android)
7.1 SDK Setup
Required SDK files:
BaseLine-1.00.aar
ShunPalm-2.00.aar
ShunPalm-LS2-2.07.aar
Location:
android/app/libs/
7.2 SDK Initialization
ShunPalm.init(ShunPalmWorker(applicationContext))
Must be called in Application.onCreate().
7.3 Palm Vein Workflow
Enrollment
Flutter requests enrollment
Native SDK starts camera
Palm features collected
Features stored via featureInsert
Palm ID returned to Flutter
Palm ID sent to backend
Recognition
Flutter requests recognition
Native SDK matches palm
User ID returned
Flutter proceeds with payment
8. NFC Integration
Implemented using NFCAdapter
Reads card UID
Returns UID to Flutter
Backend validates and processes payment
9. QR Code Integration
Implemented via SerialPortAdapter
Port: /dev/ttyHSL3
Baud Rate: 9600
QR data sent to Flutter for validation
10. Printer Integration
Printer: EM5822 (USB)
SDK: printsdk.jar
Flutter sends receipt text
Native prints formatted receipt
11. Dual Screen Support
Primary screen: Cashier UI
Secondary screen: Customer-facing display
Implemented using Android Presentation API
Flutter triggers screen updates via channel calls
12. Backend Interaction
Flutter communicates with backend for:
User registration
Palm ID mapping
Payment authorization
Transaction records
Refunds & reporting
13. Security Guidelines
No biometric data stored in Flutter
No card data stored on device
All sensitive data handled by backend
HTTPS required for all APIs
14. Error Handling
Handled scenarios:
Palm recognition timeout
NFC read failure
QR invalid
Payment declined
Hardware unavailable
All errors returned as structured responses:
{ code, message }
15. Development Timeline (Estimated)
Phase	Scope	Duration
Phase 1	Flutter UI + Backend + NFC + QR	3–4 weeks
Phase 2	Palm Vein SDK Integration	2–3 weeks
Phase 3	POS + Dual Screen + Printer	1–2 weeks
Phase 4	Testing & Optimization	1 week
Total Estimated Timeline: 7–10 weeks
16. Conclusion
This architecture ensures:
Secure biometric payments
Hardware stability
Future scalability
Clean separation of responsibilities