import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final VoidCallback? onTap;
  final bool isButton;
  final bool isSelected;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.onTap,
    this.isButton = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      selected: isSelected,
      onTap: onTap,
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }
}

class AccessibilityButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? label;
  final String? hint;

  const AccessibilityButton({
    super.key,
    required this.child,
    this.onPressed,
    this.label,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      label: label,
      hint: hint,
      isButton: true,
      onTap: onPressed,
      child: child,
    );
  }
}

class AccessibilityCard extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final VoidCallback? onTap;

  const AccessibilityCard({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      label: label,
      hint: hint,
      onTap: onTap,
      child: child,
    );
  }
}

class AccessibilityListTile extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final VoidCallback? onTap;
  final bool isSelected;

  const AccessibilityListTile({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityWrapper(
      label: label,
      hint: hint,
      onTap: onTap,
      isSelected: isSelected,
      child: child,
    );
  }
} 