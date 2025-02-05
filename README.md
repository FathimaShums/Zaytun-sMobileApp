## Getting Started
# Food App

A Flutter mobile application for food ordering with offline capabilities.

## Features

- User authentication (Login/Register)
- Food item listing with master/detail view
- Cart management
- Favorites system
- Offline support
- Dark/Light theme
- Device features integration (Location, Battery, Contacts)

## Prerequisites

Before you begin, ensure you have met the following requirements:
* Flutter SDK installed
* Android Studio/VS Code with Flutter plugins
* An Android or iOS device/emulator

## Installation

1. Clone the repository:

git clone https://github.com/FathimaShums/Zaytun-sMobileApp.git


2. Navigate to project directory:

cd [project-directory]


3. Get dependencies:
on terminal:
flutter pub get


4. Update the API base URL:
Navigate to `lib/shared/constants.dart` and update the `baseUrl` to your backend server address:
```dart
static const String baseUrl = 'http://16.170.228.132';   
```

5. Run the app:
flutter run


## Required Permissions

Android:
- Location
- Contacts
- Internet

iOS:
- Location
- Contacts

## API Dependencies

The app expects a backend server running at the specified URL with the following endpoints:
- POST /api/login
- POST /api/register
- GET /api/food-items

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details
