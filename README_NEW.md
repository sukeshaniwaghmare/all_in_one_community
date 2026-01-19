# All-in-One Community Mobile App

A modern Flutter mobile application for community management inspired by WhatsApp and Telegram designs.

## Features

### 🏘️ Multiple Community Types
- **Housing Society**: Connect with neighbors, manage maintenance, security updates
- **Village/Gram Panchayat**: Village community updates and governance
- **College**: Student community hub for academic and social activities
- **Office**: Workplace collaboration and communication
- **Open Groups**: NGO, Women Groups, Sports clubs, and interest-based communities

### 💬 Chat System
- WhatsApp-style chat interface with message bubbles
- Group chats and private messaging
- Online status indicators
- Unread message badges
- Voice message support (UI ready)
- File and image sharing (UI ready)

### 📢 Announcements
- Telegram-style broadcast messages
- Priority-based announcements (High, Medium, Low)
- Like, comment, and share functionality
- File attachments support
- Admin and moderator roles

### 👥 Community Management
- Member roles: Admin, Moderator, Member
- Community statistics and member list
- Quick actions: Events, Polls, Help, Info
- Profile management with role badges

### 🎨 Modern UI Design
- Clean, minimal, professional design
- Material Design 3 with custom theming
- Dark and light mode support
- WhatsApp green and Telegram blue color schemes
- Smooth animations and transitions
- Rounded cards and message bubbles
- Soft shadows and modern typography

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.4)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd all_in_one_community
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Project Structure

```
lib/
├── core/
│   ├── theme/          # App themes and styling
│   ├── widgets/        # Reusable UI components
│   └── utils/          # Utility functions
├── features/
│   ├── community/
│   │   ├── data/       # Data models and repositories
│   │   ├── domain/     # Business logic and entities
│   │   └── presentation/ # UI screens and widgets
│   ├── chat/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── announcements/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── provider/       # State management
└── main.dart          # App entry point
```

## Dependencies

- **flutter**: SDK
- **cupertino_icons**: iOS-style icons
- **provider**: State management
- **animations**: Smooth UI animations
- **intl**: Internationalization support

## Architecture

The app follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, screens, and widgets
- **Domain Layer**: Business logic, entities, and use cases
- **Data Layer**: Data sources, repositories, and models
- **Provider**: State management across the app

## Key Features Implementation

### 🎨 Theme System
- Light and dark themes with WhatsApp/Telegram colors
- Material Design 3 components
- Consistent color schemes and typography

### 📱 Navigation
- Bottom navigation with 4 main sections
- Smooth page transitions
- Proper state management

### 💬 Chat Interface
- WhatsApp-style message bubbles
- Read receipts and timestamps
- Group chat with sender names
- Attachment and emoji support (UI ready)

### 📢 Announcements
- Priority-based color coding
- Interactive elements (like, comment, share)
- Rich content with attachments

## Customization

### Adding New Community Types
1. Update `CommunityType` enum in `lib/features/community/domain/community_type.dart`
2. Add corresponding icons and descriptions
3. Update UI components as needed

### Theming
- Modify colors in `lib/core/theme/app_theme.dart`
- Update Material Design 3 color schemes
- Customize component themes

### Adding Features
- Follow the existing folder structure
- Implement clean architecture patterns
- Use provider for state management

## Built with ❤️ using Flutter