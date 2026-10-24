<p align="center">
  <img src="assets/images/logo.png" width="120" alt="NoCoffee logo" />
</p>

<h1 align="center">NoCoffee</h1>

<p align="center">Quit or reduce coffee and caffeine, one step at a time.</p>

NoCoffee is a mobile app (Android and iOS, built with Flutter) that helps you cut down on caffeine with a plan that steps down week by week. There are no accounts and no servers: everything stays on your device.

## Features

- **Personal plan.** Choose to reduce or quit, gradually or immediately, pick a start date and a speed (gentle, steady, fast). The weekly limits are worked out from how much you drink now.
- **Tracking.** Log drinks, edit or delete them, and look back at any day.
- **History and statistics.** Day, week and month views, a calendar, averages, change versus your usual intake, streaks and money saved.
- **Cravings.** A short flow for getting through a craving, with a log of the ones you resisted.
- **Achievements.** Milestones for streaks, weeks completed and savings.
- **Notifications.** Daily motivation, coffee reminders, daily progress, streak reminders and quiet hours. A limit warning appears inside the app.
- **Light and dark themes.**

## Privacy

All data (drinks, plan, profile, cravings, settings) is stored locally with `shared_preferences`. Nothing is uploaded and there is no analytics. "Delete all data" in Settings erases everything.

## Tech

- Flutter / Dart, Material 3
- State: `ChangeNotifier` with an `InheritedWidget`
- Storage: `shared_preferences`
- Notifications: `flutter_local_notifications`, `timezone`, `flutter_timezone`

## Getting started

```
flutter pub get
dart run flutter_launcher_icons
flutter run -d chrome
```

Notifications only work on a phone, not in the browser.

### Build an Android APK

```
flutter build apk --release
```

The file is created at `build/app/outputs/flutter-apk/app-release.apk`.

## Project structure

```
lib/
  main.dart                    app entry, routes, theme
  models.dart                  plan, entries, profile, notification settings
  state.dart                   app state, derived values, saving
  storage.dart                 local storage
  notification_service.dart    scheduled notifications
  screens/                     all screens
  widgets/common.dart          shared UI components
assets/                        logo and app icon sources
```

## Disclaimer

NoCoffee is a tracking and habit tool, not medical advice. If you are pregnant, have a health condition or take medication, talk to your doctor before changing your caffeine intake.
