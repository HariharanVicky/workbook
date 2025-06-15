import 'package:flutter/material.dart';

class SkeletonScreen extends StatelessWidget {
  final Widget child;
  
  const SkeletonScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
} 