import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../main.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final List<String> _pin = [];
  final int _pinLength = 4;
  bool _isError = false;
  int _attempts = 0;
  static const int _maxAttempts = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        MediaQuery.of(context).padding.bottom - 48,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon and Title
                  Icon(
                    Icons.security,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SpendSense',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // PIN Entry Title
                  Text(
                    'Enter PIN',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your 4-digit security PIN',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // PIN Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _pin.length
                              ? (_isError ? Colors.red : Theme.of(context).primaryColor)
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  if (_isError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Incorrect PIN. ${_maxAttempts - _attempts} attempts remaining.',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const Spacer(),

                  // Number Pad
                  Column(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (int j = 1; j <= 3; j++)
                              _buildNumberButton((i * 3 + j).toString()),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 70), // Empty space for alignment
                          _buildNumberButton('0'),
                          _buildBackspaceButton(),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Forgot PIN Option
                  TextButton(
                    onPressed: () {
                      _showForgotPinDialog();
                    },
                    child: const Text('Forgot PIN?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: () => _addDigit(number),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: _removeDigit,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: const Icon(
          Icons.backspace,
          size: 20,
        ),
      ),
    );
  }

  void _addDigit(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(digit);
        _isError = false;
      });

      if (_pin.length == _pinLength) {
        _validatePin();
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _isError = false;
      });
    }
  }

  void _validatePin() {
    final settingsProvider = context.read<SettingsProvider>();
    final enteredPin = _pin.join();
    
    if (settingsProvider.validatePin(enteredPin)) {
      // Correct PIN - record successful unlock and navigate to main app
      settingsProvider.recordSuccessfulUnlock();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } else {
      // Incorrect PIN
      setState(() {
        _isError = true;
        _attempts++;
      });

      // Clear PIN after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _pin.clear();
          });
        }
      });

      // Check if max attempts reached
      if (_attempts >= _maxAttempts) {
        _showMaxAttemptsDialog();
      }
    }
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot PIN'),
        content: const Text(
          'To reset your PIN, you will need to clear all app data. This will remove all your expenses and settings. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetAppData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset App'),
          ),
        ],
      ),
    );
  }

  void _showMaxAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Too Many Attempts'),
        content: const Text(
          'You have exceeded the maximum number of PIN attempts. Please try again later.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _attempts = 0;
                _isError = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetAppData() async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.removePin();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }
} 