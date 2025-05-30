# Temperature Converter App

A Flutter application for converting temperatures between Fahrenheit and Celsius with an intuitive user interface, conversion history tracking, and smooth animations.

## Features

- **Bidirectional Temperature Conversion**: Convert between Fahrenheit to Celsius and Celsius to Fahrenheit
- **Input Validation**: Comprehensive error handling and user feedback
- **Conversion History**: Track and display previous conversions with timestamps
- **Responsive Design**: Adaptive layout for both portrait and landscape orientations
- **Smooth Animations**: Enhanced UX with fade and scale animations
- **Haptic Feedback**: Tactile feedback for better user interaction
- **Material Design 3**: Modern UI following Material Design principles

## Architecture Overview

The application follows a clean, modular architecture with clear separation of concerns:

```
TemperatureConverterApp (MaterialApp)
├── TemperatureConverterScreen (StatefulWidget)
├── ConversionHistory (Model Class)
└── UI Components (Widgets)
```

### Core Components

#### 1. **TemperatureConverterApp**
- **Type**: `StatelessWidget`
- **Purpose**: Root application widget that configures the MaterialApp
- **Key Features**:
    - Material Design 3 theming
    - Custom color scheme with blue seed color
    - Styled elevated buttons and cards
    - Debug banner disabled

#### 2. **TemperatureConverterScreen**
- **Type**: `StatefulWidget` with `TickerProviderStateMixin`
- **Purpose**: Main screen containing all conversion functionality
- **Key Features**:
    - Manages conversion state and user input
    - Handles animations and UI transitions
    - Responsive layout adaptation
    - History management

#### 3. **ConversionHistory**
- **Type**: Model class
- **Purpose**: Represents a single conversion history entry
- **Properties**:
    - `conversionType`: String identifier (e.g., "F to C")
    - `inputValue`: Original temperature value
    - `outputValue`: Converted temperature value
    - `timestamp`: When the conversion occurred
    - `displayText`: Formatted string for UI display

## 🔧 Technical Implementation

### State Management

The application uses Flutter's built-in state management with `StatefulWidget`:

```dart
// Core state variables
bool _isFahrenheitToCelsius = true;  // Conversion direction
double? _convertedValue;             // Result value
String _errorMessage = '';           // Validation errors
List<ConversionHistory> _conversionHistory = []; // History tracking
```

### Animation System

Two animation controllers provide smooth UI transitions:

1. **Result Animation Controller**: 500ms fade-in animation for conversion results
2. **Button Animation Controller**: 150ms scale animation for button press feedback

```dart
// Animation setup
AnimationController _resultAnimationController;
AnimationController _buttonAnimationController;
Animation<double> _resultFadeAnimation;
Animation<double> _buttonScaleAnimation;
```

### Temperature Conversion Logic

#### Fahrenheit to Celsius
```dart
double _fahrenheitToCelsius(double fahrenheit) {
  return (fahrenheit - 32) * 5 / 9;
}
```

#### Celsius to Fahrenheit
```dart
double _celsiusToFahrenheit(double celsius) {
  return celsius * 9 / 5 + 32;
}
```

### Input Validation

Comprehensive validation ensures data integrity:

- **Empty Input Check**: Prompts user to enter a value
- **Numeric Validation**: Uses `double.tryParse()` for safe conversion
- **Format Filtering**: `FilteringTextInputFormatter` allows only valid numeric input (including negative values and decimals)

## UI Components

### 1. Conversion Type Selector
- **Widget**: `Card` with `RadioListTile` widgets
- **Purpose**: Allows users to choose conversion direction
- **Features**:
    - Visual formula display
    - Automatic state reset on selection change

### 2. Input Section
- **Widget**: `Card` with `TextField`
- **Purpose**: Temperature value input with validation
- **Features**:
    - Dynamic labeling based on conversion type
    - Input formatting and validation
    - Clear button functionality
    - Submit on enter key

### 3. Result Display
- **Widget**: Animated `Card` with `FadeTransition`
- **Purpose**: Shows conversion result with visual feedback
- **Features**:
    - Animated appearance
    - Large, prominent result display
    - Contextual equation display

### 4. History Section
- **Widget**: `Card` with `ListView`
- **Purpose**: Displays conversion history
- **Features**:
    - Scrollable list (max height: 200px)
    - Timestamp formatting (relative time)
    - Clear history functionality
    - Empty state handling

## Responsive Design

The application adapts to different screen orientations:

### Portrait Mode
- Vertical stack layout
- Single-column arrangement
- Full-width components

### Landscape Mode
- Two-column layout using `Row`
- Left column: Conversion controls
- Right column: History display
- Optimized space utilization

## User Experience Enhancements

### Haptic Feedback
- **Light Impact**: Successful conversion
- **Selection Click**: Clear operations
- **Medium Impact**: History clearing

### Animation Timing
- **Result Fade-in**: 500ms with ease-in-out curve
- **Button Press**: 150ms scale animation
- **Smooth Transitions**: All state changes are animated

### Error Handling
- Real-time input validation
- Clear error messages
- Visual feedback for all actions
- Graceful degradation

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone or create the project**:
   ```bash
   flutter create temperature_converter
   cd temperature_converter
   ```

2. **Replace the content** of `lib/main.dart` with the provided code

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

### Dependencies

The application uses only Flutter's core dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # No additional dependencies required
```

## Testing Considerations

### Unit Testing Areas
- Temperature conversion algorithms
- Input validation logic
- History management functions
- Timestamp formatting

### Widget Testing Areas
- UI component rendering
- User interaction flows
- State management
- Animation behavior

### Integration Testing Areas
- Complete conversion workflows
- History persistence
- Responsive layout behavior
- Error handling scenarios

## Customization Options

### Theme Modification
```dart
// In TemperatureConverterApp.build()
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.blue, // Change primary color
  brightness: Brightness.light,
),
```

### Animation Timing
```dart
// Adjust animation durations
_resultAnimationController = AnimationController(
  duration: const Duration(milliseconds: 500), // Modify timing
  vsync: this,
);
```

### History Limits
```dart
// Add history limit in _performConversion()
if (_conversionHistory.length > 50) {
  _conversionHistory.removeLast();
}
```

## Performance Considerations

- **Efficient State Management**: Minimal rebuilds using targeted `setState()` calls
- **Memory Management**: Proper disposal of controllers and focus nodes
- **List Performance**: Constrained history list height prevents performance issues
- **Animation Optimization**: Hardware-accelerated animations using Flutter's animation system

## Future Enhancement Ideas

- **Temperature Scale Support**: Add Kelvin conversion
- **History Persistence**: Save history using SharedPreferences or local database
- **Export Functionality**: Export history to CSV or PDF
- **Unit Preferences**: Remember user's preferred conversion direction
- **Dark Theme**: Add dark mode support
- **Accessibility**: Enhanced screen reader support
- **Internationalization**: Multi-language support

## Code Quality

The codebase follows Flutter best practices:
- **Clear Naming**: Descriptive variable and method names
- **Documentation**: Comprehensive inline comments
- **Separation of Concerns**: Logical component organization
- **Error Handling**: Robust validation and error management
- **Performance**: Efficient resource usage and disposal
