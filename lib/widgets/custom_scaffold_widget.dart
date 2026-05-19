import 'package:flutter/material.dart';

class CustomScaffoldWidget extends StatefulWidget {
  const CustomScaffoldWidget({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  State<CustomScaffoldWidget> createState() => _CustomScaffoldWidgetState();
}

class _CustomScaffoldWidgetState extends State<CustomScaffoldWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: SafeArea(child: widget.body),
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
