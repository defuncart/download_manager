import 'package:download_manager/home/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({
    super.key,
    required this.onAddUrl,
  });

  final void Function(String) onAddUrl;

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late TextEditingController _controller;
  var _canAdd = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController()
      ..addListener(() {
        final canAdd = _controller.text.isValidUrl;
        if (_canAdd != canAdd) {
          setState(() => _canAdd = canAdd);
        }
      });
    Clipboard.getData(Clipboard.kTextPlain).then((result) {
      if (result != null && result.text != null) {
        _controller.text = result.text!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Item'),
      content: TextField(
        controller: _controller,
      ),
      actions: [
        TextButton(
          onPressed: _canAdd
              ? () {
                  widget.onAddUrl(_controller.text);
                  Navigator.of(context).pop();
                }
              : null,
          child: Text('Add'),
        ),
      ],
    );
  }
}
