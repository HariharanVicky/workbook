import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInput extends StatefulWidget {
  final double? initialValue;
  final Function(double) onAmountChanged;
  final String? errorText;
  final String currency;
  final bool enabled;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  const AmountInput({
    super.key,
    this.initialValue,
    required this.onAmountChanged,
    this.errorText,
    this.currency = '\$',
    this.enabled = true,
    this.focusNode,
    this.controller,
  });

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!.toStringAsFixed(2);
    }
    _focusNode.addListener(_onFocusChange);
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
    if (!_focusNode.hasFocus) {
      _formatAmount();
    }
  }

  void _formatAmount() {
    if (_controller.text.isEmpty) return;
    try {
      final amount = double.parse(_controller.text);
      _controller.text = amount.toStringAsFixed(2);
      widget.onAmountChanged(amount);
    } catch (e) {
      // Invalid input, keep as is
    }
  }

  @override
  Widget build(BuildContext context) {
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
        prefixText: '${widget.currency} ',
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (value.isEmpty) {
          widget.onAmountChanged(0);
          return;
        }
        try {
          final amount = double.parse(value);
          widget.onAmountChanged(amount);
        } catch (e) {
          // Invalid input, ignore
        }
      },
    );
  }
} 