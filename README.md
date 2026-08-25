# Smart Wallet - Personal Finance App

A personal Flutter app for tracking Airtime, Data, Expenses, Income and Savings Goals.  
It can automatically detect Airtime & Data purchases from incoming SMS messages.

**Designed for personal use on Android (tested style for Infinix phones).**

## Features
- Dark purple theme with gradient balance card
- Auto SMS detection for Airtime / Data / generic expenses
- Manual add transactions
- Savings Goals with progress tracking
- Local storage (data stays on your phone)
- Beautiful modern UI matching the mockups

## How to build and install on your Infinix phone

### Option 1 – Easiest (recommended if you have a computer)

1. Install **Flutter** on your Windows / Mac / Linux computer:  
   https://docs.flutter.dev/get-started/install

2. Download this project folder (`smart_wallet`).

3. Open a terminal inside the `smart_wallet` folder and run:

```bash
flutter pub get
flutter build apk --release
```

4. The APK will be created at:  
   `build/app/outputs/flutter-apk/app-release.apk`

5. Copy the APK to your Infinix phone (USB, Google Drive, WhatsApp, etc.).

6. On your phone:
   - Go to **Settings → Security** (or Privacy) and enable **Install from unknown sources** / **Allow from this source**.
   - Open the APK file and install it.
   - When the app asks for SMS permission → **Allow** (needed for auto-sync).

### Option 2 – Using online builders (no computer setup)

You can upload this project to free services such as:
- Codemagic
- Appetize.io
- FlutterFlow (import)
- Or ask a friend who has Flutter installed to build the APK for you.

### Important notes for Infinix / Android
- On Android 10+ the app must be given SMS permission for auto-detection to work.
- Some Infinix/XOS versions restrict background SMS listening – if auto-sync stops, reopen the app once.
- The app works fully offline. All data is stored only on your device.

## Project structure
```
lib/
  models/          → Transaction & SavingsGoal
  services/        → SMS sync + state management
  screens/         → Dashboard, Transactions, Savings, Add Transaction
  main.dart
android/.../AndroidManifest.xml  → SMS permissions already added
```

Enjoy your personal Smart Wallet!  
Made just for you.
