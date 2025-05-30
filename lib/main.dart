import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

/// Main application widget that sets up the MaterialApp with theme configuration
class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const TemperatureConverterScreen(),
    );
  }
}

/// Model class to represent a conversion history entry
class ConversionHistory {
  final String conversionType;
  final double inputValue;
  final double outputValue;
  final DateTime timestamp;

  ConversionHistory({
    required this.conversionType,
    required this.inputValue,
    required this.outputValue,
    required this.timestamp,
  });

  /// Formats the history entry for display
  String get displayText {
    return '$conversionType: ${inputValue.toStringAsFixed(1)} => ${outputValue.toStringAsFixed(2)}';
  }
}

/// Main screen widget containing the temperature conversion functionality
class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with TickerProviderStateMixin {
  // Controllers and state variables
  final TextEditingController _temperatureController = TextEditingController();
  final FocusNode _temperatureFocusNode = FocusNode();

  // Conversion state
  bool _isFahrenheitToCelsius = true; // Default conversion type
  double? _convertedValue;
  String _errorMessage = '';

  // History management
  final List<ConversionHistory> _conversionHistory = [];

  // Animation controllers for enhanced UX
  late AnimationController _resultAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _resultFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initialize animation controllers for smooth UI transitions
  void _initializeAnimations() {
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _resultFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeInOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _temperatureFocusNode.dispose();
    _resultAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  /// Converts Fahrenheit to Celsius using the formula: °C = (°F - 32) × 5/9
  double _fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Converts Celsius to Fahrenheit using the formula: °F = °C × 9/5 + 32
  double _celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  /// Validates user input and performs temperature conversion
  void _performConversion() {
    setState(() {
      _errorMessage = '';
      _convertedValue = null;
    });

    // Input validation
    if (_temperatureController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a temperature value';
      });
      return;
    }

    final double? inputValue = double.tryParse(_temperatureController.text.trim());
    if (inputValue == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    // Perform conversion based on selected type
    double result;
    String conversionType;

    if (_isFahrenheitToCelsius) {
      result = _fahrenheitToCelsius(inputValue);
      conversionType = 'F to C';
    } else {
      result = _celsiusToFahrenheit(inputValue);
      conversionType = 'C to F';
    }

    // Update state and add to history
    setState(() {
      _convertedValue = result;
      _conversionHistory.insert(0, ConversionHistory(
        conversionType: conversionType,
        inputValue: inputValue,
        outputValue: result,
        timestamp: DateTime.now(),
      ));
    });

    // Trigger result animation
    _resultAnimationController.forward();

    // Provide haptic feedback for better UX
    HapticFeedback.lightImpact();
  }

  /// Clears all input and results
  void _clearAll() {
    setState(() {
      _temperatureController.clear();
      _convertedValue = null;
      _errorMessage = '';
    });
    _resultAnimationController.reset();
    HapticFeedback.selectionClick();
  }

  /// Clears the conversion history
  void _clearHistory() {
    setState(() {
      _conversionHistory.clear();
    });
    HapticFeedback.mediumImpact();

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History cleared'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Builds the conversion type selection radio buttons
  Widget _buildConversionSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversion Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            RadioListTile<bool>(
              title: const Text('Fahrenheit to Celsius (°F → °C)'),
              subtitle: const Text('°C = (°F - 32) × 5/9'),
              value: true,
              groupValue: _isFahrenheitToCelsius,
              onChanged: (value) {
                setState(() {
                  _isFahrenheitToCelsius = value!;
                  _convertedValue = null;
                  _errorMessage = '';
                });
                _resultAnimationController.reset();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            RadioListTile<bool>(
              title: const Text('Celsius to Fahrenheit (°C → °F)'),
              subtitle: const Text('°F = °C × 9/5 + 32'),
              value: false,
              groupValue: _isFahrenheitToCelsius,
              onChanged: (value) {
                setState(() {
                  _isFahrenheitToCelsius = value!;
                  _convertedValue = null;
                  _errorMessage = '';
                });
                _resultAnimationController.reset();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the temperature input section
  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Temperature',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _temperatureController,
              focusNode: _temperatureFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: _isFahrenheitToCelsius ? 'Temperature in °F' : 'Temperature in °C',
                hintText: _isFahrenheitToCelsius ? 'e.g., 32.0' : 'e.g., 0.0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  _isFahrenheitToCelsius ? Icons.thermostat : Icons.ac_unit,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: _temperatureController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _temperatureController.clear();
                    setState(() {
                      _convertedValue = null;
                      _errorMessage = '';
                    });
                    _resultAnimationController.reset();
                  },
                )
                    : null,
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              onSubmitted: (_) => _performConversion(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _buttonAnimationController.forward().then((_) {
                          _buttonAnimationController.reverse();
                        });
                        _performConversion();
                      },
                      icon: const Icon(Icons.calculate),
                      label: const Text('Convert'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the conversion result display
  Widget _buildResultSection() {
    if (_convertedValue == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _resultFadeAnimation,
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Conversion Result',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_convertedValue!.toStringAsFixed(2)}°${_isFahrenheitToCelsius ? 'C' : 'F'}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isFahrenheitToCelsius
                    ? '${_temperatureController.text}°F = ${_convertedValue!.toStringAsFixed(2)}°C'
                    : '${_temperatureController.text}°C = ${_convertedValue!.toStringAsFixed(2)}°F',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the conversion history section
  Widget _buildHistorySection() {
    if (_conversionHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No conversion history yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Perform a conversion to see history here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conversion History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _conversionHistory.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final history = _conversionHistory[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    history.displayText,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  subtitle: Text(
                    _formatTimestamp(history.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Icon(
                    history.conversionType == 'F to C'
                        ? Icons.thermostat
                        : Icons.ac_unit,
                    color: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Formats timestamp for display in history
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temperature Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            // Responsive layout that adapts to orientation
            if (orientation == Orientation.landscape) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildConversionSelector(),
                          const SizedBox(height: 16),
                          _buildInputSection(),
                          const SizedBox(height: 16),
                          _buildResultSection(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildHistorySection(),
                    ),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildConversionSelector(),
                    const SizedBox(height: 16),
                    _buildInputSection(),
                    const SizedBox(height: 16),
                    _buildResultSection(),
                    const SizedBox(height: 16),
                    _buildHistorySection(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}