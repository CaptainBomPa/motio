import 'package:flutter/material.dart';

import 'dynamic_field.dart';

class IngredientField extends StatefulWidget {
  final List<TextEditingController> controllers;
  final GlobalKey<AnimatedListState> listKey;

  IngredientField({Key? key, required this.controllers, required this.listKey}) : super(key: key);

  @override
  _IngredientFieldState createState() => _IngredientFieldState();
}

class _IngredientFieldState extends State<IngredientField> {
  void addField() {
    setState(() {
      final controller = TextEditingController();
      widget.controllers.add(controller);
      widget.listKey.currentState?.insertItem(widget.controllers.length - 1);
    });
  }

  void removeField(int index) {
    setState(() {
      final controller = widget.controllers[index];
      widget.controllers.removeAt(index);
      widget.listKey.currentState?.removeItem(
        index,
            (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: DynamicField(
            controller: controller,
            labelText: 'Składnik',
            onRemove: () {},
          ),
        ),
        duration: const Duration(milliseconds: 300),
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        controller.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReorderableListView(
          key: widget.listKey,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final controller = widget.controllers.removeAt(oldIndex);
              widget.controllers.insert(newIndex, controller);
            });
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (int index = 0; index < widget.controllers.length; index++)
              ListTile(
                key: ValueKey(widget.controllers[index]),
                title: DynamicField(
                  controller: widget.controllers[index],
                  labelText: '',
                  onRemove: () => removeField(index),
                ),
                leading: Icon(Icons.drag_handle, color: Theme.of(context).iconTheme.color),
                contentPadding: EdgeInsets.symmetric(horizontal: 0), // to ensure full width
              ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.add_circle, color: Theme.of(context).iconTheme.color),
          onPressed: addField,
        ),
      ],
    );
  }
}
