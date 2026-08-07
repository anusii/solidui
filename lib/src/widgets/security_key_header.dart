/// Header component for the SecurityKeyUI widget.
///
/// Copyright (C) 2024-2025, Software Innovation Institute, ANU.
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
/// Authors: Ashley Tang

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/constants/ui.dart';

/// A header widget displaying title, WebID, and message for security key UI.

class SecurityKeyHeader extends StatelessWidget {
  /// Creates a security key header.

  const SecurityKeyHeader({
    required this.title,
    required this.webId,
    required this.message,
    super.key,
  });

  /// The title to display.

  final String title;

  /// The WebID to display (null if not logged in).

  final String? webId;

  /// The instructional message to display.

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SecurityLayout.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title heading.
          Text(title, style: SecurityThemeTextStyles.heading(context)),

          // Green divider under heading.
          Container(
            height: SecurityLayout.dividerHeight,
            color: SecurityThemeColors.accent(context),
            margin: SecurityLayout.dividerMargin,
          ),

          // "Currently logged in as:" label.
          Text(
            SecurityStrings.webIdLabel,
            style: SecurityThemeTextStyles.label(context),
          ),

          // WebID on separate line.
          Padding(
            padding: SecurityLayout.webIdPadding,
            child: Text(
              webId ?? SecurityStrings.notLoggedIn,
              style: SecurityThemeTextStyles.webId(
                context,
                isLoggedIn: webId != null,
              ),
            ),
          ),

          // Instructions text.
          Text(message, style: SecurityThemeTextStyles.body(context)),
        ],
      ),
    );
  }
}
