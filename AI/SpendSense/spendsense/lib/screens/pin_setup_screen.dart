import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  final int _pinLength = 4;
  bool _isConfirming = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final currentPin = settingsProvider.pin;
    final isPinEnabled = settingsProvider.pinEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security PIN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PIN Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPinEnabled ? Icons.lock : Icons.lock_open,
                          color: isPinEnabled ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PIN Security',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPinEnabled 
                          ? 'PIN is enabled and required to access the app'
                          : currentPin != null
                              ? 'PIN is set but not enabled'
                              : 'No PIN is set',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // PIN Setup Section
            if (currentPin == null) ...[
              _buildPinSetupSection(),
            ] else ...[
              _buildPinManagementSection(),
            ],

            const SizedBox(height: 32),

            // PIN Dots
            Center(
              child: Column(
                children: [
                  Text(
                    _isConfirming ? 'Confirm PIN' : 'Enter PIN',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (index) {
                      final currentPinList = _isConfirming ? _confirmPin : _pin;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < currentPinList.length
                              ? (_isError ? Colors.red : Theme.of(context).primaryColor)
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  if (_isError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

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
          ],
        ),
      ),
    );
  }

  Widget _buildPinSetupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set Security PIN',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Create a 4-digit PIN to secure your expense data',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isConfirming ? null : _startPinSetup,
                icon: const Icon(Icons.security),
                label: const Text('Set PIN'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPinManagementSection() {
    final settingsProvider = context.read<SettingsProvider>();
    final isPinEnabled = settingsProvider.pinEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage PIN',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Enable/Disable PIN
        ListTile(
          leading: Icon(
            isPinEnabled ? Icons.lock : Icons.lock_open,
            color: isPinEnabled ? Colors.green : Colors.grey,
          ),
          title: Text(isPinEnabled ? 'Disable PIN' : 'Enable PIN'),
          subtitle: Text(
            isPinEnabled 
                ? 'PIN will not be required to access the app'
                : 'PIN will be required to access the app'
          ),
          trailing: Switch(
            value: isPinEnabled,
            onChanged: (value) async {
              if (value) {
                await settingsProvider.enablePin();
              } else {
                await settingsProvider.disablePin();
              }
            },
          ),
        ),

        // Change PIN
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Change PIN'),
          subtitle: const Text('Set a new 4-digit PIN'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _startPinSetup,
        ),

        // Remove PIN
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Remove PIN', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Remove PIN security completely'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _showRemovePinDialog,
        ),
      ],
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

  void _startPinSetup() {
    setState(() {
      _pin.clear();
      _confirmPin.clear();
      _isConfirming = false;
      _isError = false;
      _errorMessage = '';
    });
  }

  void _addDigit(String digit) {
    final currentPinList = _isConfirming ? _confirmPin : _pin;
    
    if (currentPinList.length < _pinLength) {
      setState(() {
        currentPinList.add(digit);
        _isError = false;
        _errorMessage = '';
      });

      if (currentPinList.length == _pinLength) {
        _processPinEntry();
      }
    }
  }

  void _removeDigit() {
    final currentPinList = _isConfirming ? _confirmPin : _pin;
    
    if (currentPinList.isNotEmpty) {
      setState(() {
        currentPinList.removeLast();
        _isError = false;
        _errorMessage = '';
      });
    }
  }

  void _processPinEntry() async {
    if (!_isConfirming) {
      // First PIN entry - move to confirmation
      setState(() {
        _isConfirming = true;
      });
    } else {
      // Confirmation PIN entry - validate
      final firstPin = _pin.join();
      final confirmPin = _confirmPin.join();
      
      if (firstPin == confirmPin) {
        // PINs match - save it
        final settingsProvider = context.read<SettingsProvider>();
        await settingsProvider.setPin(firstPin);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN set successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // PINs don't match
        setState(() {
          _isError = true;
          _errorMessage = 'PINs do not match. Please try again.';
          _confirmPin.clear();
        });
      }
    }
  }

  void _showRemovePinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove PIN'),
        content: const Text(
          'Are you sure you want to remove the PIN security? This will make your expense data accessible without any protection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final settingsProvider = context.read<SettingsProvider>();
              await settingsProvider.removePin();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN removed successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
} 