/// A page to create resources with ACL inheritance
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
/// Authors: Anushka Vidanage

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show writePod, setInheritKeyDir;
import 'package:solidui/solidui.dart' show SolidScaffold;

import 'package:demopod/constants/app.dart';

// A widget to create a resource with inherited ACL.
//
// The resource will be created inside a parent directory and the ACL of that
// directory will be inherited for that resource.
//
// If resource need to be encrypted, a single encryption key assigned to the
// parent directory will be used for the encryption.
class CreateAclInheritedFile extends StatefulWidget {
  const CreateAclInheritedFile({super.key});

  @override
  CreateAclInheritedFileState createState() => CreateAclInheritedFileState();
}

class CreateAclInheritedFileState extends State<CreateAclInheritedFile> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _resourcePathController = TextEditingController();
  final TextEditingController _parentDirectoryController =
      TextEditingController();

  // Toggle switch value
  bool _isEncrypted = true;

  @override
  void dispose() {
    // Dispose controllers when widget is removed
    _resourcePathController.dispose();
    _parentDirectoryController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve entered values
      String resourcePath = _resourcePathController.text.trim();
      String parentDirectory = _parentDirectoryController.text.trim();

      final demoTtlContent = createDemoTtlStr(resourcePath);
      final messenger = ScaffoldMessenger.of(context);

      try {
        if (_isEncrypted) {
          if (!context.mounted) return;
          await writePod(
            resourcePath,
            demoTtlContent,
            encrypted: _isEncrypted,
            createAcl: false,
            overwrite: true,
            inheritKeyFrom: parentDirectory,
          );
        } else {
          // First check and create the corresponding directory
          await setInheritKeyDir(parentDirectory);
          if (!context.mounted) return;
          // ignore: use_build_context_synchronously
          await writePod(
            resourcePath,
            demoTtlContent,
            encrypted: _isEncrypted,
            createAcl: false,
          );
        }

        messenger.showSnackBar(
          const SnackBar(content: Text('Resource created successfully!')),
        );
      } on Object catch (e, trace) {
        debugPrint(e.toString());
        debugPrint(trace.toString());

        messenger.showSnackBar(
          const SnackBar(
            content: Text('There was a problem creating resource! '
                'Please try again later.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      scaffoldAppBar: AppBar(
        title: const Text('Create a resource with ACL inheritance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Instruction paragraph
              const Text(
                'Fill out the following two text fields according to the below '
                'instructions. The "Resource Path" field should contain the path '
                'to the resource itself including the actual resource name. An '
                'example would be "parentDir/sampleRes.ttl". The "Parent Dir"'
                'should contain the path to the actual parent directory where the '
                'resource will inherit the ACL file from. An example would be '
                '"parentDir".',
                style: TextStyle(fontSize: 16.0, height: 1.5),
              ),
              const SizedBox(height: 24),

              // Resource path field
              TextFormField(
                controller: _resourcePathController,
                decoration: const InputDecoration(
                  labelText: 'Resource Path',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a resource path';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Parent directory field
              TextFormField(
                controller: _parentDirectoryController,
                decoration: const InputDecoration(
                  labelText: 'Parent Directory',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a parent directory';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Encrypted Toggle Switch
              SwitchListTile(
                title: const Text(
                  'Encrypted',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _isEncrypted
                      ? 'This resource content will be stored in encrypted form.'
                      : 'This resource content will not be encrypted.',
                ),
                value: _isEncrypted,
                onChanged: (bool value) {
                  setState(() {
                    _isEncrypted = value;
                  });
                },
                thumbColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.green;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create resource'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
