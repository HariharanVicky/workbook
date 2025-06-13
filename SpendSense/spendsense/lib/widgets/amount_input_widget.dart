import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../components/amount_input.dart';

class AmountInputWidget extends StatelessWidget {
  final double? initialValue;
  final Function(double) onAmountChanged;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  const AmountInputWidget({
    super.key,
    this.initialValue,
    required this.onAmountChanged,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    
    return AmountInput(
      initialValue: initialValue,
      onAmountChanged: onAmountChanged,
      errorText: errorText,
      currency: settingsProvider.currency,
      enabled: enabled,
      focusNode: focusNode,
      controller: controller,
    );
  }
} 