# Add Write functionality to your App

The example app is currently a read-only/browse-only Solid Pod app generated from the solidui template. It can browse, upload, and download files via solidui's SolidFile widget, but has no code path that constructs and writes app-generated content. 

This exercise adds a basic `Write to POD functionality` to the existing app in simplistic way. 

"Title + Description -> Save to POD" form: a new page with two text inputs and a save button that JSON-encodes the input and writes it as an encrypted file into the app's POD data directory, confirmed with a success snackbar.

## Dependencies

First you need to add `solidpod` to your `pubspec.yaml` file if its not already there. The latest version is `solidpod: ^1.0.13`. After adding run `flutter pub get` to get the latest version.

## Create a new "Add Note" file

Create a new dart file `lib/screens/add_note.dart` and add the following import statements. These will import all the necessary packages to this page.

```dart
/// Add note functionality. This is a simple example of how to add a note to your Solid Pod using Solidpod

library;

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart';

import 'package:solidui/solidui.dart';
```

## Add a Stateful Widget to your Add Note file

You now need to add the basic UI to enable inputs from the user. For this use case, lets add two inputs `Title` and `Description` to the UI.
Use the following code snippet as example. You can simply copy this as well.

```dart
class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Save Note',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Please enter a title'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Please enter a description'
                            : null,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : () async {},
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save to POD'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Add OnSave function

Next you can add the actual save functionality to your form. The following code snippet will give you a detailed functionality with some validation checks in place. But for a simple save function you only need to parse the data to a format you prefer and call the `writePod()` function with the parsed data.

```dart
Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (!await isUserLoggedIn()) return;

      if (!mounted) return;
      await getKeyFromUserIfRequired(context, widget);

      // Encode the data to a JSON string
      final jsonString = jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text,
      });
      final fileName = 'note_${DateTime.now().millisecondsSinceEpoch}'
          '.json.enc.ttl';

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);

      // Write the data to the POD
      await writePod(fileName, jsonString, encrypted: true);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Note saved to POD.'),
          backgroundColor: Colors.green,
        ),
      );

      _titleController.clear();
      _descriptionController.clear();
    } on NotLoggedInException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to save a note.'),
          backgroundColor: Colors.red,
        ),
      );
    } on AccessForbiddenException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied while saving the note.'),
          backgroundColor: Colors.red,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
```

## Add menue item

Finally add a menu item to the `SolidScaffold` and point that to the "Add Note" page to create the necessary navigation.

```dart
SolidMenuItem(
  icon: Icons.note_add,
  title: 'Add Note',
  tooltip: '''

    **Add Note**

    Tap here to add a titled note to your POD, encrypted.

    ''',
  child: AddNote(),
),
```

Now restart the app and test your newly implemented functionality.

Congratulations! You have now successfully implemented a functionality to write data into PODs.