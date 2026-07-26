# alionhr

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



lib/
├── main.dart
│
├── core/
│   ├── network/
│   │   └── api_client.dart
│   ├── storage/
│   │   └── secure_storage.dart
│   └── constants/
│       └── api_constants.dart
│
├── models/
│   ├── user.dart
│   ├── attendance.dart
│   └── leave.dart
│
├── services/
│   ├── auth_service.dart
│   ├── attendance_service.dart
│   ├── leave_service.dart
│   └── employee_service.dart
│
└── ui/
    ├── auth/
    │   ├── login_view.dart
    │   └── login_view_model.dart
    │
    ├── home/
    │   ├── home_view.dart
    │   └── home_view_model.dart
    │
    ├── attendance/
    │   ├── attendance_view.dart
    │   └── attendance_view_model.dart
    │
    ├── leave/
    │   ├── leave_view.dart
    │   └── leave_view_model.dart
    │
    └── profile/