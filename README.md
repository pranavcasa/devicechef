# DeviceChef

DeviceChef is a clean, modular, and fully functional Flutter Android app built as part of a technical interview assessment. The app demonstrates authentication, real-time battery and device info retrieval, native image picker integration, and a recipe manager with pagination and search — using only provider, http, and shared\_preferences.

📱 Features

✅ Authentication

* Login using DummyJSON API (username + password)
* Persistent session using shared\_preferences
* Logout functionality via drawer navigation

✅ Profile

* Displays user profile info (name, email, avatar)
* Data sourced from login response

✅ Battery Overlay (Real-time)

* Persistent battery info visible on all screens
* Uses Android EventChannel and BroadcastReceiver to fetch:

  * Battery percentage
  * Charging status (Charging / Full / Discharging)

✅ Device Info

* Shows:

  * Device brand
  * Model
  * Manufacturer
  * Android version
* Uses Android MethodChannel (no external packages)

✅ Native Image Picker

* Platform-specific integration (MethodChannel)
* Opens device gallery to select image
* Displays selected image with option to clear or replace

✅ Recipes Management

* Paginated list of recipes (fetched from DummyJSON API or mocked)
* Infinite scroll using ScrollController
* Search bar to filter recipes by name
* Placeholder for recipe detail, edit, delete, and add

🛠️ Technologies Used

* Flutter (Android only)
* State Management: Provider
* Networking: http
* Persistence: shared\_preferences
* Native Integration: Kotlin (MethodChannel & EventChannel)
* UI: Material Design

📸 Screenshots

(Add screenshots here)

🚀 How to Run

* Clone the repo
* Run flutter pub get
* Make sure you use Android device or emulator
* Run with flutter run

📋 Notes

* No third-party packages like device\_info\_plus or image\_picker used
* All platform-specific functionality built using MethodChannel and EventChannel
* Project is modular and extendable

📌 To Do

* Implement full recipe CRUD (Add, Edit, Delete)
* Add recipe detail page
* Enhance UI polish and loading/error states
* Add local caching for offline access

🧪 Test Credentials (DummyJSON)

Username: kminchelle
Password: 0lelplR

📄 License

This project is part of a technical interview assignment and not intended for commercial use.

—

Would you like this exported as a downloadable README.md file?
