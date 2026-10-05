# Lucky Delivery

Flutter starter project for the Lucky Delivery customer and delivery-partner app.

## Included now
- Customer and Delivery Partner roles
- Create delivery order
- Customer and partner dashboard
- Agreed delivery amount (not percentage based)
- Basic account verification status UI
- English, Hindi and Gujarati language options
- GitHub Actions workflow that generates a debug APK

## Build
```bash
flutter pub get
flutter run
flutter build apk --debug
```

The GitHub Actions workflow can build the debug APK without requiring Gradle wrapper files in the repository; it generates the Android project through Flutter first.

Production integrations such as Firebase authentication/database, maps, notifications, real payments, KYC/verification, chat, and signed release builds should be connected after the core UI and backend requirements are finalized.
