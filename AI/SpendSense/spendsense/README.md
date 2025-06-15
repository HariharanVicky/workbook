# SpendSense

A Flutter application for tracking personal expenses and income.

## Features

- Track daily expenses and income
- Categorize transactions
- View monthly summaries
- Analyze spending patterns
- Customize categories
- Dark/Light theme support
- Multiple currency support

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/spendsense.git
```

2. Navigate to the project directory:
```bash
cd spendsense
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic
├── widgets/        # Reusable widgets
├── navigation/     # Navigation logic
└── main.dart       # Entry point
```

## Architecture

The app follows a clean architecture pattern with:

- **Models**: Data structures and business objects
- **Providers**: State management using Provider pattern
- **Services**: Business logic and data operations
- **Screens**: UI components and user interactions
- **Widgets**: Reusable UI components

## Testing

Run tests using:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- SQLite for local database
- fl_chart for data visualization
