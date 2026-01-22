/// Initial setup page constants.
///
// Time-stamp: <Friday 2025-01-10 13:34:52 +1100 Graham Williams>
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

/// Colour variables used in initial setup screen.

const lightGreen = Color.fromARGB(255, 120, 219, 137);

/// Colour variables used in initial setup screen.

const darkBlue = Color.fromARGB(255, 7, 87, 153);

/// Colour variables used in initial setup screen.

// const kTitleTextColor = Color(0xFF30384D);

/// Padding value for initial setup screen.

// const double kDefaultPadding = 20.0;

/// Text string variables used for the welcome message.

const initialStructureWelcome = 'Welcome to the Solid Pod Setup Wizard';

/// Text string variables as the title of the message box.

const initialStructureTitle = 'Solid Pod';

/// Text string variables used for informing the user about the first-time
/// connection and security key requirement.

const initialStructureMsg =
    'You have connected to your Solid Pod using this app for the first time. '
    'A security key is required to encrypt and protect your data. '
    'You must remember this key to access the data associated with this app.';

/// The string key of input form for the input of security key

const securityKeyStr = '_security_key';

/// The string key of the input form for retyping the security key.

const securityKeyStrReType = '__security_key';

/// Markdown tooltip text for the security key input field.

const securityKeyTooltip =
    'A security key is required to encrypt and protect your data.';
