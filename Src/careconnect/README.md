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

# 5. Link to test coverage report


# 6. Known issues or limitations
  1. Lack of AI LLM Credits (Used to create prompts)
  2. 

# 7. Team member contributions this week
     Brice Tikum
     David Oguh
     Sivakumar Ganesan


# 8. AI usage summary (what did AI help with?)

    As a team, we have used GitHub CoPilot and Claude for VS code AI to develop the screens and unit test .dart files. Also, we asked AI to fix the compilation and run time errors by providing a correct prompt.

    We input the AI with the screen dart file to generate testase and the AI created the valid unit testcases and ran thos to make sure the screen functionality is not broken.


  
