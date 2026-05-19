import 'package:flutter/material.dart';

class DataIsEmptyWidget extends StatelessWidget {
  const DataIsEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Aucune donnée",
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}
