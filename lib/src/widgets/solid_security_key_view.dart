/// A widget to view private key data in a Solid Pod.
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
/// Authors: Anushka Vidanage, Graham Williams, Ashley Tang, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/widgets/solid_security_key_utils.dart';

/// A widget to show the user all the encryption keys stored in their Solid Pod.

class SolidSecurityKeyView extends StatefulWidget {
  /// Constructor for the widget.

  const SolidSecurityKeyView({
    required this.keyInfo,
    required this.title,
    super.key,
  });

  /// Data of the key file.

  final String keyInfo;

  // Title of the page.

  final String title;

  @override
  State<SolidSecurityKeyView> createState() => _SolidSecurityKeyViewState();
}

class _SolidSecurityKeyViewState extends State<SolidSecurityKeyView> {
  /// Scaffold key for managing widget state.

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // The main screen layout with an app bar and a data table.

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: loadedScreen(widget.keyInfo),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  /// A widget to display the loaded encryption key data in a table.

  Widget loadedScreen(String keyData) {
    final encFileData = parseEncKeyContent(keyData);

    // Map the data into rows for the DataTable.

    final dataRows = encFileData.entries.map((entry) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              entry.key as String,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 600,
              child: Text(
                entry.value[1] as String,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();

    // Display the table of encryption key data.

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DataTable(
              columnSpacing: 30.0,
              columns: const [
                DataColumn(
                  label: Text(
                    'Parameter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Value',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: dataRows,
            ),
          ],
        ),
      ),
    );
  }
}
