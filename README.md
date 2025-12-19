# Flutter Chat App

A modern, feature-rich chat application built with Flutter that supports user registration, authentication, and real-time messaging between multiple users.

## 🚀 Features

### User Management
- **User Registration**: Sign up with full name, email, password, and age validation
- **Secure Login**: Email and password authentication with form validation
- **Auto-Login**: Automatic login for returning users
- **Multi-User Support**: Unlimited user accounts with unique email validation

### Messaging System
- **Private Chats**: One-on-one messaging between registered users
- **Real-Time Updates**: Messages appear instantly (local implementation)
- **Message History**: Persistent message storage across app sessions
- **Message Timestamps**: Shows exact time for today's messages, relative dates for older ones

### Chat Interface
- **Chat List**: WhatsApp-style interface showing all conversations
- **Last Message Preview**: Displays the most recent message in each chat
- **Unread Message Badges**: Red counters for unread messages
- **Message Sorting**: Chats automatically sorted by most recent activity
- **Message Status**: Clear indication of sent messages with "You:" prefix

### User Experience
- **Material Design**: Modern, intuitive UI following Material Design principles
- **Responsive Layout**: Optimized for mobile devices
- **Form Validation**: Comprehensive input validation with error messages
- **Persistent Storage**: All data saved locally using SharedPreferences

## 📱 Screenshots

*(Add screenshots of your app here)*

## 🛠️ Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language for Flutter
- **SharedPreferences**: Local data persistence
- **Intl Package**: Date and time formatting
- **Material Design**: UI component library

## 📋 Prerequisites

Before running this project, make sure you have:

- Flutter SDK (version 3.10.4 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- A connected device or emulator

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/flutter-chat-app.git
   cd flutter-chat-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Usage

### Getting Started
1. Launch the app
2. Create an account using the "Create Account" button
3. Fill in your details and sign up
4. Log in with your credentials

### Chatting
1. From the home screen, tap on any registered user
2. Start typing messages in the chat interface
3. Messages are sent instantly and saved automatically
4. Return to the chat list to see all conversations

### Features Overview
- **Signup**: Register with name, email, password, and age
- **Login**: Authenticate with email and password
- **Chat List**: View all users and recent conversations
- **Private Messaging**: Chat with individual users
- **Message History**: All messages persist between sessions

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── app.dart               # App routing and theme
├── screens/
│   ├── login_screen.dart  # User login interface
│   ├── signup_screen.dart # User registration interface
│   ├── home_screen.dart   # Chat list and user overview
│   └── chat_screen.dart   # Individual chat interface
└── test/
    └── widget_test.dart   # Basic widget tests
```

## 🔒 Data Storage

The app uses SharedPreferences for local data persistence:

- **Users**: Stored as JSON array with user details
- **Messages**: Stored as JSON array with sender, receiver, message, and timestamp
- **Session**: Current user email and login status
- **Read Status**: Last read timestamps for each conversation

## 🧪 Testing

Run the included tests:

```bash
flutter test
```

## 📝 Code Quality

The project follows Flutter best practices:

- **Linting**: Passes `flutter analyze` with no errors
- **Code Formatting**: Consistent Dart formatting
- **Error Handling**: Proper async error handling
- **State Management**: Clean stateful widget management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

If you have any questions or issues:

1. Check the [Issues](https://github.com/your-username/flutter-chat-app/issues) page
2. Create a new issue with detailed description
3. Contact the maintainers

## 🚀 Future Enhancements

- [ ] Push notifications for new messages
- [ ] Message encryption and security
- [ ] Group chat functionality
- [ ] Message reactions and media sharing
- [ ] Online/offline user status
- [ ] Message search functionality
- [ ] Dark mode theme
- [ ] Backend integration for real-time messaging

---

**Built with ❤️ using Flutter**
