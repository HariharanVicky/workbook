import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';

class AmountInput extends StatefulWidget {
  final double? initialValue;
  final Function(double) onAmountChanged;
  final String? errorText;
  final bool enabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  const AmountInput({
    super.key,
    this.initialValue,
    required this.onAmountChanged,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    this.controller,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late NumberFormat _formatter;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    _updateFormatter(context.read<SettingsProvider>().currency);
    
    if (widget.initialValue != null) {
      _controller.text = _formatter.format(widget.initialValue);
    }

    _focusNode.addListener(_onFocusChange);
  }

  void _updateFormatter(String currency) {
    _formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
      locale: currency == 'INR' ? 'en_IN' : 'en_US',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsProvider = context.watch<SettingsProvider>();
    if (_formatter.locale != (settingsProvider.currency == 'INR' ? 'en_IN' : 'en_US')) {
      _updateFormatter(settingsProvider.currency);
      if (_controller.text.isNotEmpty) {
        final value = _parseAmount(_controller.text);
        if (value != null) {
          _controller.text = _formatter.format(value);
        }
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Remove currency formatting when focused
      final value = _parseAmount(_controller.text);
      if (value != null) {
        _controller.text = value.toString();
      }
    } else {
      // Add currency formatting when unfocused
      final value = _parseAmount(_controller.text);
      if (value != null) {
        _controller.text = _formatter.format(value);
      }
    }
  }

  double? _parseAmount(String text) {
    if (text.isEmpty) return null;
    try {
      return double.parse(text.replaceAll(RegExp(r'[^\d.-]'), ''));
    } catch (e) {
      return null;
    }
  }

  void _onChanged(String value) {
    final amount = _parseAmount(value);
    if (amount != null) {
      widget.onAmountChanged(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: '${settingsProvider.currencySymbol} ',
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
      ),
      onChanged: _onChanged,
    );
  }
} 