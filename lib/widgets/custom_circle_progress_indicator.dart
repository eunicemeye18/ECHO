import 'dart:developer';

import 'package:flutter/material.dart';

class CustomCircleProgressIndicator extends StatefulWidget {
  const CustomCircleProgressIndicator({
    super.key,
    this.color,
    this.value,
  });
  final Color? color;
  final double? value;

  @override
  State<CustomCircleProgressIndicator> createState() =>
      _CustomCircleProgressIndicatorState();
}

class _CustomCircleProgressIndicatorState
    extends State<CustomCircleProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    log("🎯 PROGRESS INDICATOR - value: ${widget.value}");
    return CircularProgressIndicator(
      color: widget.color ?? Theme.of(context).colorScheme.primary,
      value: widget.value,
      strokeWidth: 3,
    );
  }
}
