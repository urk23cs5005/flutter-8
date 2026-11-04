# Product Search using Google Firestore - Ex. 8

Flutter app that takes a product name, queries the pre-filled Firestore collection `products`
with `where('name', isEqualTo: text).limit(1).get()` (first as typed, then in Title Case, e.g.
"rice" -> "Rice"), and shows name, quantity and price. Quantity < 5 shows a red "Low Stock!";
no match shows "Product not found". The app only reads; it never adds data.

Documents in `products` (add them by hand in the Firebase Console, as in Ex. 7):

| name   | quantity (number) | price (number) |
|--------|-------------------|----------------|
| Rice   | e.g. 25           | e.g. 60        |
| Sugar  | 3                 | 45             |
| ...    |                   |                |

Search is case-sensitive, so store names in Title Case (Rice, Sugar...).

## 1. Create the Flutter project files

```bash
cd product_search_firestore_app
flutter create .        # generates android/ etc. (keeps lib/ and pubspec.yaml)
flutter pub get
```

## 2. Firebase setup (your own Firebase account; same as Ex. 7)

1. Firebase Console -> Add project (you can reuse the Ex. 7 project) -> **Add Android app**.
   Package name = the `applicationId` in `android/app/build.gradle(.kts)`.
2. Download **google-services.json** into `android/app/`.
3. Gradle changes (use the style your project has):

   **Newer Flutter (Kotlin DSL: `*.gradle.kts`)**
   - `android/settings.gradle.kts`, `plugins { }`: `id("com.google.gms.google-services") version "4.4.2" apply false`
   - `android/app/build.gradle.kts`, `plugins { }`: `id("com.google.gms.google-services")`
   - same file, `defaultConfig { }`: `minSdk = 23`
   - same file: `dependencies { implementation(platform("com.google.firebase:firebase-bom:33.5.1")) }`

   **Older Flutter (Groovy: `*.gradle`)**
   - `android/build.gradle`, `buildscript { dependencies { classpath 'com.google.gms:google-services:4.4.2' } }`
   - `android/app/build.gradle`, bottom: `apply plugin: 'com.google.gms.google-services'`
   - `defaultConfig { minSdkVersion 23 }` and
     `dependencies { implementation platform('com.google.firebase:firebase-bom:33.5.1') }`
4. Create the Firestore database (test mode for the lab, so the app can read) and add the product documents.
5. Run on an Android emulator or phone:

```bash
flutter run
```

## Structure

```
lib/main.dart            ProductSearchApp, SearchPage (TextField, SEARCH, Firestore query, result card)
test/widget_test.dart    Tests for the Title Case and low-stock rules
screenshots/             Output screenshots from the lab record (incl. Firestore console)
```
