/// A page to read resources with ACL inheritance
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

import 'package:solidpod/solidpod.dart' show readPod;
import 'package:solidui/solidui.dart' show SolidScaffold;

// A widget to create a resource with inherited ACL.
//
// The resource will be created inside a parent directory and the ACL of that
// directory will be inherited for that resource.
//
// If resource need to be encrypted, a single encryption key assigned to the
// parent directory will be used for the encryption.
class ReadAclInheritedFile extends StatefulWidget {
  const ReadAclInheritedFile({super.key});

  @override
  ReadAclInheritedFileState createState() => ReadAclInheritedFileState();
}

class ReadAclInheritedFileState extends State<ReadAclInheritedFile> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController _resourcePathController = TextEditingController();

  // File content
  String _fileContent = '';

  @override
  void dispose() {
    // Dispose controllers when widget is removed
    _resourcePathController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve entered values
      String resourcePath = _resourcePathController.text.trim();

      try {
        String fileContent = await readPod(resourcePath);

        setState(() {
          _fileContent = fileContent;
        });
      } catch (e) {
        setState(() {
          _fileContent = 'Error reading file: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      scaffoldAppBar: AppBar(
        title: const Text('Read a resource with ACL inheritance'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Instruction paragraph
                const Text(
                  'The "Resource Path" field should contain the path '
                  'to the resource itself including the actual resource name '
                  'and extention. An example would be "parentDir/sampleRes.ttl".',
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

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('read resource'),
                ),

                const SizedBox(height: 10),
                // Display file content if available
                if (_fileContent.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _fileContent,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
