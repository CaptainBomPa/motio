import 'package:flutter/material.dart';

import 'dynamic_field.dart';

class StepField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final GlobalKey<AnimatedListState> listKey;

  StepField({
    Key? key,
    required this.controllers,
    required this.listKey,
  }) : super(key: key);

  void addField() {
    final controller = TextEditingController();
    controllers.add(controller);
    listKey.currentState?.insertItem(controllers.length - 1);
  }

  void removeField(int index) {
    final controller = controllers[index];
    listKey.currentState?.removeItem(
      index,
          (context, animation) =>
          SizeTransition(
            sizeFactor: animation,
            child: DynamicField(
              controller: controller,
              labelText: 'Krok',
              onRemove: () {},
            ),
          ),
      duration: const Duration(milliseconds: 300),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      controller.dispose();
      controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedList(
          key: listKey,
          initialItemCount: controllers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index, animation) {
            final controller = controllers[index];
            return SizeTransition(
              sizeFactor: animation,
              child: DynamicField(
                controller: controller,
                labelText: 'Krok',
                onRemove: () => removeField(index),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: addField,
        ),
      ],
    );
  }
}
