# UniBall - Flutter Mobile App

UniBall is a mobile application designed for university football players and coaches to organize training sessions, manage team communication, and track player engagement. This repository contains the Flutter frontend that provides an intuitive mobile interface for the UniBall platform.

_Coupled with [Uniball_backend](https://github.com/ZeeroCoo0l/Uniball_backend)_

## 📱 Project Overview

UniBall addresses common challenges in student football teams at Stockholm University's Department of Computer and Systems Sciences (DSV):
- Scattered communication through large WhatsApp groups (100+ members)
- Last-minute training announcements causing low attendance
- Lack of structured training sessions and exercise variety
- Difficulty in fair team division and player engagement tracking

The mobile app provides a user-friendly interface for players and administrators to manage their football activities efficiently.

## ✨ Key Features

### For Players
- **Training Schedule**: View upcoming training sessions with clear date, time, and location
- **Easy Registration**: Quick "Yes/No" attendance confirmation for training sessions
- **Team Formation**: Participate in fair team divisions through shake-to-randomize functionality
- **Statistics & Awards**: View personal achievements and team leaderboards
- **Voting System**: Vote for MVP, best goal, and best assist after training sessions

### For Administrators
- **Training Management**: Create, edit, and cancel training sessions
- **Exercise Library**: Access and randomize training exercises for varied sessions
- **Team Administration**: Manage team members and assign admin privileges
- **Attendance Tracking**: Monitor player participation and engagement

## 🏗️ Technical Architecture

### Technology Stack
- **Framework:** Flutter (Dart)
- **State Management:** Flutter's built-in setState
- **Authentication:** Supabase Auth with Google OAuth and email authentication
- **Backend Communication:** HTTP requests to Spring Boot API
- **Device Features:** Shake detection for team randomization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (for iOS development) or Android Emulator
- Access to UniBall Spring Boot backend _(check the link in the top of the file!)_
- Supabase project credentials

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  intl: ^0.18.1              # Date formatting and localization
  google_nav_bar: ^5.0.7     # Bottom navigation bar
  google_sign_in: ^6.3.0     # Google OAuth authentication
  http: ^1.3.0               # HTTP requests to backend
  supabase_flutter: ^2.8.4   # Supabase integration
  uuid: ^4.5.1               # Unique identifier generation
  image_picker: ^1.1.2       # Profile image selection
  shake: ^3.0.0              # Device shake detection
```

### Key Package Usage
- **intl**: Swedish date formatting for training schedules
- **google_nav_bar**: Clean bottom navigation between main app sections
- **google_sign_in + supabase_flutter**: Seamless authentication flow
- **http**: Communication with Spring Boot REST API
- **shake**: Interactive team randomization feature
- **image_picker**: Profile picture management

## 🔧 Configuration

### Backend Connection Setup
The app communicates with a Spring Boot backend. Ensure:

1. **Backend URL Configuration**: Set the correct `_baseURL` in `backend_communication.dart`
2. **Network Permissions**: Android requires internet permission (should be included by default)
3. **CORS Configuration**: Backend should allow requests from mobile app

### Authentication Setup
1. **Supabase Project**: Create a project at supabase.com
2. **Google OAuth**: Configure Google Sign-In in Supabase dashboard
3. **Client ID**: Add your Supabase client ID to `google_login_service.dart`
4. **URL and Anon Key for Supabase**: Add the credentials in the `main.dart`.

## 📱 User Interface

### Design Principles
- **Football Theme**: Green color scheme inspired by football field
- **Intuitive Navigation**: Clear icons and labels for all functions
- **Mobile-First**: Optimized for touch interactions and mobile screens

## 🧪 Testing

Project contains tests for all entities.

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🔒 Authentication & Security

### Authentication Flow
1. User initiates Google Sign-In
2. Supabase handles OAuth with Google
3. JWT token received and stored locally
4. Token included in all backend API requests
5. Backend validates token with Supabase

### Security Considerations
- User session management through Supabase
- Profile images stored in Supabase Storage with user-specific access

## 📊 State Management

The app uses Flutter's built-in state management with `setState()`:
- **Local State**: Individual widget state using StatefulWidget
- **App State**: Shared data passed through widget tree
- **User Session**: Managed through Supabase client

## Build Configuration
- Update `_baseURL` to production backend URL
- Ensure proper Supabase production credentials
- Configure app signing for distribution

## 🔮 Future Enhancements

### Planned Features
- **Push Notifications**: Training reminders and announcements
- **Calendar Integration**: Sync with Google Calendar
- **Weather Integration**: OpenWeather API for training conditions
- **Enhanced Statistics**: More detailed player analytics
- **Multi-Sport Support**: Expand beyond football
- **Multi-University**: Support for other universities

### Technical Improvements
- **State Management**: Migrate to Provider or Bloc for better scalability
- **Offline Support**: Cache training data for offline viewing
- **Performance**: Optimize for larger team sizes
- **Testing**: Comprehensive widget and integration tests

## 📱 Device Compatibility

### Supported Platforms
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+

## 👥 Development Team

**Group 15:9 - PVT 2025**
- Development approach: Agile methodology with Scrum
- User-centered design with iterative improvements
- Cross-platform development for maximum accessibility

## 📄 License

This project is developed as part of a university course at Stockholm University, Department of Computer and Systems Sciences (DSV).

---

**Course:** PVT 2025  
**Institution:** Stockholm University - DSV  
**Target Users:** University football players and administrators
