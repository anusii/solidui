/// Resource list view widget for initial setup screen.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
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
/// Authors: Zheyuan Xu, Anushka Vidanage, Tony Chen

library;

import 'package:flutter/material.dart';

/// A StatefulWidget to properly manage the ScrollController for the resource
/// list in the dialog.

class ResourceListView extends StatefulWidget {
  const ResourceListView({super.key, required this.extractedParts});

  final List<String?> extractedParts;

  @override
  State<ResourceListView> createState() => _ResourceListViewState();
}

class _ResourceListViewState extends State<ResourceListView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: widget.extractedParts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final resLink = widget.extractedParts[index];
          if (resLink == null) return const SizedBox.shrink();
          final isFolder = resLink.endsWith('/');
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(
                  isFolder
                      ? Icons.folder_outlined
                      : Icons.insert_drive_file_outlined,
                  size: 20,
                  color: isFolder ? Colors.amber : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    resLink,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
