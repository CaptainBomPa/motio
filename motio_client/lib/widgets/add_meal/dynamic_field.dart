import 'package:flutter/material.dart';

class DynamicField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onRemove;
  final String labelText;

  const DynamicField({
    Key? key,
    required this.controller,
    required this.onRemove,
    required this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(labelText: labelText),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
