# TechnoPark - Mobile Workspace Booking App

TechnoPark is a mobile application prototype to help users book free workspace or meeting rooms for meetings, studying, discussions, group work, and other productive activities.

This project focuses on implementing a functional **Login Screen**, **Register Screen**, and a semi-static **Home Screen** based on the final UI/UX design created in Figma.

## Project Overview

TechnoPark allows users to access available workspace rooms after logging in. The app is built with a clean, modern, and professional mobile interface using Flutter. The current version does not use a backend or database, because the main objective of this UTS project is to demonstrate UI slicing, form validation, navigation, and basic app structure.

## Main Features

* Functional login screen
* New user registration screen
* Basic in-memory authentication
* Demo account login
* Email and password validation
* Semi-static home screen
* List of available workspace rooms
* Capacity-based room information
* Room cards with workspace-style thumbnails
* Operational status card
* Booking rule card
* Bottom navigation UI
* Snackbar feedback for room interaction
* Professional Flutter project structure

## Booking Rules

The application follows these booking rules:

1. One account can only have one booking for the same usage date.
2. Booking duration is fixed at 2 hours.
3. A user may create multiple bookings on the same day as long as the usage dates are different.
4. TechnoPark operates from 09:00 to 19:00.
5. Sundays and national holidays are closed.
6. In this UTS version, the booking feature is represented as a UI prototype and semi-static interaction.

## Demo Account

You can use the following demo account to log in:

```text
Email    : rangga@student.ac.id
Password : 123456
```

Users can also create a new account through the Register Screen. The registered account is stored in memory while the application is running.

## Available Rooms

The Home Screen displays 9 workspace rooms:

| Room Name              | Capacity |
| ---------------------- | -------: |
| Ruang Adi Soemarmo     | 4 people |
| Ruang Balapan          | 4 people |
| Ruang Jebres           | 4 people |
| Ruang Tirtonadi        | 6 people |
| Ruang Purwosari        | 6 people |
| Ruang Solo Kota        | 6 people |
| Ruang Batik Solo Trans | 8 people |
| Ruang Kerten           | 8 people |
| Ruang Kleco            | 8 people |

## Tech Stack

* Flutter
* Dart
* Google Fonts
* Material Design
* Figma for UI/UX design
* GitHub for version control

## Project Structure

```text
lib/
├── main.dart
├── constants/
│   └── app_colors.dart
├── data/
│   └── room_data.dart
├── models/
│   ├── app_user.dart
│   └── room_model.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── register_screen.dart
├── services/
│   └── auth_service.dart
└── widgets/
    ├── booking_rule_card.dart
    ├── custom_input_field.dart
    ├── primary_button.dart
    ├── room_card.dart
    ├── room_thumbnail.dart
    ├── status_card.dart
    └── workspace_illustration.dart
```

## UI/UX Design

The UI/UX design was created in Figma with a modern, clean, and professional style. The design uses a card-based layout, consistent spacing, rounded corners, soft shadows, and a technology-oriented color palette.

### Figma Design Links

https://www.figma.com/design/h87JVrFceledQpQvllijUX/TechnoPark---Mobile-App-UI-UX-Design?node-id=35-2&t=cZlhn537SvhKmzcF-1

## How to Run the Project

Make sure Flutter is already installed on your device.

1. Clone this repository:

```bash
git clone <repository-url>
```

2. Move into the project folder:

```bash
cd technopark_app
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

The project is intended to run on an Android emulator, such as Pixel 7.

## Current Implementation Scope

This project is created for the Mobile Computing UTS assignment. The current implementation includes:

* Login screen slicing from Figma
* Register screen for new users
* Basic form validation
* In-memory authentication
* Navigation from Login to Home
* Semi-static Home Screen with room list
* Basic room interaction using Snackbar

The booking system is not connected to a real backend or database yet. Future development may include real booking logic, persistent user data, booking history, room availability checking, and calendar-based validation.
