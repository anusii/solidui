/// Pre-flight checks and friendly error dialogues for POD writes.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart'
    show
        AccessFailedException,
        AccessForbiddenException,
        KeyManager,
        NotLoggedInException,
        ResourceNotDecryptableException,
        SecurityKeyNotAvailableException,
        isUserLoggedIn;

import 'package:solidui/src/utils/solid_alert.dart' show alert;

/// Outcome of a [checkPodWritable] pre-flight check.

enum PodWriteGateOutcome {
  /// The user is logged in and a verified security key is cached.
  /// Callers may proceed with the write.

  writable,

  /// The user is not currently logged in. Callers should abort the
  /// write and any in-memory state change that depended on it.

  notLoggedIn,

  /// The user is logged in but the security key is not cached (or has
  /// failed verification). Callers should abort the write.

  securityKeyMissing,
}

/// Silently checks whether the Pod can currently be written to.

Future<PodWriteGateOutcome> checkPodWritable() async {
  if (!await isUserLoggedIn()) {
    return PodWriteGateOutcome.notLoggedIn;
  }
  if (!await KeyManager.hasSecurityKey()) {
    return PodWriteGateOutcome.securityKeyMissing;
  }
  return PodWriteGateOutcome.writable;
}

/// Pre-flight gate that callers should invoke before any Pod write.

Future<bool> ensurePodWritable(
  BuildContext context, {
  String actionDescription = 'saving changes',
}) async {
  final outcome = await checkPodWritable();
  if (outcome == PodWriteGateOutcome.writable) return true;
  if (!context.mounted) return false;

  switch (outcome) {
    case PodWriteGateOutcome.notLoggedIn:
      await alert(
        context,
        'You need to log in to your POD before $actionDescription.\n\n'
        'Please log in and try again.',
        'Login Required',
      );
      return false;

    case PodWriteGateOutcome.securityKeyMissing:
      await alert(
        context,
        'Your Security Key is not currently cached, '
        'so $actionDescription cannot be completed.\n\n'
        'Please provide your Security Key and try again.',
        'Security Key Required',
      );
      return false;

    case PodWriteGateOutcome.writable:
      return true;
  }
}

/// Render a friendly dialogue for a [solidpod] exception that surfaced
/// from a read or write operation, returning `true` when the exception
/// was recognised.

Future<bool> showPodAccessExceptionDialog(
  BuildContext context,
  Object error,
) async {
  if (!context.mounted) return false;

  if (error is NotLoggedInException) {
    await alert(
      context,
      'You are not logged in to your POD, so this operation cannot be '
      'completed.\n\nPlease log in and try again.',
      'Login Required',
    );
    return true;
  }

  if (error is SecurityKeyNotAvailableException) {
    await alert(
      context,
      'Your Security Key is not available, so this operation cannot be '
      'completed.\n\nPlease provide your Security Key and try again.',
      'Security Key Required',
    );
    return true;
  }

  if (error is ResourceNotDecryptableException) {
    await alert(
      context,
      'The data on your POD could not be decrypted. This usually means '
      'the cached Security Key does not match the one used to encrypt '
      'the file.\n\nPlease re-enter the correct Security Key and try '
      'again.',
      'Decryption Failed',
    );
    return true;
  }

  if (error is AccessForbiddenException) {
    await alert(
      context,
      'Access to the requested resource on your POD is forbidden.\n\n'
      'You may not have permission to perform this operation.',
      'Access Forbidden',
    );
    return true;
  }

  if (error is AccessFailedException) {
    await alert(
      context,
      'A request to your POD failed. Please check your network '
      'connection and try again.',
      'POD Request Failed',
    );
    return true;
  }

  return false;
}
