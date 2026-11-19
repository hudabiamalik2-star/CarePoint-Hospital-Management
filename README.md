# CarePoint Hospital Management App

A Flutter front-end-only internship demo. It uses fictional sample data and local device storage (SharedPreferences); it does not connect to a backend or online database.

## Included modules
- Splash screen and mock role selection (Admin, Doctor, Receptionist)
- Remembered demo session
- Dashboard with patient/doctor/appointment/revenue cards and a sample activity chart
- Patient records: add, edit, delete, search
- Doctor directory: add, edit, delete, search, availability toggle
- Appointments: book, reschedule, cancel/delete, update status (Pending/Confirmed/Completed/Cancelled)
- Billing: create/edit/delete invoices and update Paid/Unpaid status
- Profile, logout, dark-mode toggle
- Local JSON persistence through SharedPreferences
- GitHub Actions workflow to build the Android APK in the cloud

## Demo login
- Email: `admin@carepoint.com`
- Password: `123456`
- Role: choose Admin, Doctor, or Receptionist

This is a mock front-end login for demonstration only, not production authentication.

## Build locally (if Android SDK is installed)
```bash
flutter create . --platforms=android
flutter pub get
flutter run
flutter build apk --release
```

## Build APK without installing Android Studio on your laptop
1. Create a GitHub repository.
2. Upload the contents of this project to the repository (keep `.github/workflows/build-apk.yml`).
3. Open the repository's **Actions** tab.
4. Run **Build Android APK** (or push to `main`).
5. When the workflow finishes, open the run and download the `hospital-management-release-apk` artifact.

The APK is built on GitHub-hosted infrastructure. A GitHub account and internet access are required. Review and test the generated APK on an Android device before submission.

## Submission checklist
- GitHub repository URL
- Release APK artifact (download it from the Actions run)
- 2–3 minute demo video showing login, dashboard, patients, doctors, appointments, billing and profile
- README and screenshots

## Important scope notes
- The app uses fictional sample patient information only.
- No real patient or medical records should be entered.
- The dashboard chart is illustrative sample activity, not live analytics.
- This starter implementation provides basic CRUD/search and local persistence; verify the app and adjust branding/screenshots to match your internship's expectations before submitting.
