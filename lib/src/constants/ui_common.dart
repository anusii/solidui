/// Common UI constants and helper functions.
///
/// Copyright (C) 2025-2026, Software Innovation Institute, ANU.
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
/// Authors: Ashley Tang, Jess Moore, Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidui/src/constants/ui_text_styles.dart';

/// Class for icon sizing in list items.

class ListIconSize {
  /// Icon width.

  static const double width = 50;

  /// Icon height.

  static const double height = 50;

  /// Width for two icons side by side.

  static const double twoIconWidth = (width * 2) + gap;

  /// Gap between icons.

  static const double gap = 15;
}

/// Icon shape decoration for list items.

ShapeDecoration listIconShape =
    const ShapeDecoration(color: Colors.grey, shape: CircleBorder());

/// Normal height for data loading screens.

const double normalLoadingScreenHeight = 200.0;

/// Small vertical spacing for widgets.

const smallGapV = SizedBox(height: 10.0);

/// Large vertical spacing for widgets.

const largeGapV = SizedBox(height: 40.0);

/// Build a heading widget with customisable style.
///
/// Arguments:
/// - [text] - The text to display.
/// - [fontSize] - The font size.
/// - [fontWeight] - The font weight (optional).
/// - [color] - The text colour (optional).
/// - [padding] - The padding around the text (optional).

Row buildHeading({
  required String text,
  required double fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? padding,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        child: Padding(
          padding: padding == null ? EdgeInsets.zero : EdgeInsets.all(padding),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight ?? FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ),
      ),
    ],
  );
}

/// Make a sub heading using SubHeadingStyle as default.
///
/// Arguments:
/// - [text] - The text to display.
/// - [bold] - Whether to use bold font weight.
/// - [addColor] - Whether to add the default colour.
/// - [addPadding] - Whether to add padding.

Widget makeSubHeading(
  String text, {
  bool bold = true,
  bool addColor = true,
  bool addPadding = true,
}) =>
    buildHeading(
      text: text,
      fontSize: SubHeadingStyle.fontsize,
      fontWeight: (bold) ? SubHeadingStyle.fontweight : FontWeight.normal,
      color: (addColor) ? SubHeadingStyle.fontcolor : Colors.black,
      padding: (addPadding) ? SubHeadingStyle.padding : 0,
    );

/// Make a heading using HeadingStyle as default.
///
/// Arguments:
/// - [text] - The text to display.
/// - [bold] - Whether to use bold font weight.
/// - [addColor] - Whether to add the default colour.
/// - [addPadding] - Whether to add padding.

Widget makeHeading(
  String text, {
  bool bold = true,
  bool addColor = true,
  bool addPadding = true,
}) =>
    buildHeading(
      text: text,
      fontSize: HeadingStyle.fontsize,
      fontWeight: (bold) ? HeadingStyle.fontweight : FontWeight.normal,
      color: (addColor) ? HeadingStyle.fontcolor : Colors.black,
      padding: (addPadding) ? HeadingStyle.padding : 0,
    );
