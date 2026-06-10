# careconnect

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# 1. Project Description

This project is for CareConnect which is a cross-platform Flutter application that bridges the gap between Short-Term Memory Loss (STML) users and their caregivers.

It is Built for iOS and Android operating systems, and it provides tailored, role-based dashboards to track daily routines, manage medications, send SOS alerts, and access local caregiver resources. 

This mobile application aims to enhance the independence of STML users while alleviating burnout for family and professional caregivers. By utilizing Flutter’s cross-platform capabilities, the app delivers a unified, highly accessible digital ecosystem.

# 2. List of screens
1. Open the visual studio code.
2. Update all the .dart files for the following screens
   a) create account
   b) login screen
   c) dashboard screen
   d) my appointments
   e) my reminders
   f) my medications
   g) reminders
   h) profile
   i) settings

# 3. How to run the app
There is no need to compile separately. But its a good practice to build the project as follows.

Install the project dependencies
Add all the requireed .dart and test classses
Go to the project folder by cd  your_project_folder

# Clean and Build the project
  Flutter clean
  Flutter Pub Get

# Run the project
  flutter run
  
# Run the project using chrome os and use the same port in mobile device browser
  flutter run -d chrome (if need to run on chrome browser using chrome os)
  
  Flutter : Select Device from VS Code
  Use iOS  (iphone simulator got opened up)
  Open the safari browser 
  enter http://localhost:<<port number from the "flutter run -d chrome>>/
  CareConnect STML app opened up

# 4. How to run the tests

The project uses Flutter's built-in test framework (`flutter_test`) along with `mocktail` for mocking.

**Prerequisites:** Ensure you have run `flutter pub get` to install all dependencies before running tests.

### Run all tests
```
flutter test
```

### Run a specific test file
```
flutter test test/screens/login_screen_test.dart
```

### Run tests with coverage
```
flutter test --coverage
```
This generates a coverage report at `coverage/lcov.info`.

### Test structure
The test suite is organized as follows:
- `test/` — Unit and widget tests for screens (create account, user profile, user settings)
- `test/screens/` — Widget tests for all screens (dashboard, login, appointments, reminders, medications, health metrics, health reports, pharmacy, care team)
- `test/providers/` — Unit tests for all Riverpod providers (account, appointments, care team, health metrics, health reports, medications)

### Run only provider tests
```
flutter test test/providers/
```

### Run only screen tests
```
flutter test test/screens/
```

# 5. Link to test coverage report

The HTML coverage report is generated locally from the `lcov.info` file produced by `flutter test --coverage`.
Current overall line coverage: **75.0%** (1895 of 2525 lines).

---

### Windows — Step-by-step instructions

**Prerequisites:**
- Flutter SDK installed and on PATH
- Git for Windows installed (provides the Perl runtime used by `genhtml`)
- All project dependencies installed (`flutter pub get`)

**Step 1 — Navigate to the project folder**

Open **PowerShell** and navigate to wherever you cloned the repository:
```powershell
cd "path\to\SWEN661_Team8\Src\careconnect"
```
> Replace `path\to\` with the actual path on your machine where you cloned the repo.

**Step 2 — Run tests and generate the coverage data file**
```powershell
flutter test --coverage
```
This runs the full test suite and outputs `coverage/lcov.info`.

**Step 3 — Download the `genhtml` script (one-time setup)**

Open **Git Bash** (right-click in the project folder → "Open Git Bash here") and run:
```bash
curl -o genhtml https://raw.githubusercontent.com/linux-test-project/lcov/v1.16/bin/genhtml
```
> Only needs to be done once. The `genhtml` file will be saved in the project root.

**Step 4 — Create the output directory and generate the HTML report**

Still in **Git Bash**, run:
```bash
mkdir -p coverage/html
perl genhtml coverage/lcov.info -o coverage/html
```
> Git Bash must be used here (not PowerShell) because `genhtml` relies on Unix tools that come bundled with Git for Windows.

**Step 5 — Open the report in your browser**

In **PowerShell**:
```powershell
start coverage\html\index.html
```
Or simply navigate to `coverage\html\index.html` in File Explorer and double-click it.

---

### macOS / Linux
```bash
# Step 1 — Run tests
flutter test --coverage

# Step 2 — Install lcov
brew install lcov        # macOS
sudo apt install lcov    # Ubuntu/Debian

# Step 3 — Generate the HTML report
genhtml coverage/lcov.info -o coverage/html

# Step 4 — Open the report
open coverage/html/index.html   # macOS
xdg-open coverage/html/index.html  # Linux
```

---

The full report will be available at `coverage/html/index.html` after running the steps above.

A hosted coverage report has not yet been published.

# 6. Known issues or limitations
  1. Lack of AI LLM Credits — Limited access to AI/LLM API credits restricts the ability to generate dynamic prompts and AI-assisted features within the app.
  2. No backend persistence — App data (reminders, medications, appointments) is stored in-memory via Riverpod providers and is lost when the app is closed. Integration with a persistent backend (e.g., Firebase) is not yet implemented.
  3. SOS alert feature is not fully implemented — The SOS alert/emergency contact notification flow is a placeholder and does not send real notifications or messages to caregivers.
  4. iOS simulator required for iOS testing — Testing on iOS requires Xcode and a macOS machine; the app cannot be built or tested on Windows/Linux for the iOS target.
  5. Push notifications limited to device — `flutter_local_notifications` only supports local on-device notifications; real-time caregiver push notifications across devices are not yet supported.

# 7. Team member contributions this week
     Brice Tikum
     David Oguh
     Sivakumar Ganesan