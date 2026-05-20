/// User-facing messages for the WebID validation outcomes defined by
/// `solidpod`. The validation pipeline itself lives in `solidpod` and is
/// UI-agnostic; this module translates a [WebIdCheckResult] into the English
/// wording shown in the sharing dialogs.
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

import 'package:solidpod/solidpod.dart'
    show WebIdCheckResult, WebIdCheckStatus, isValidIpv4;

/// Build a user-facing message for a non-valid [result], or `null` when the
/// result is [WebIdCheckStatus.valid] and no message is needed.
///
/// [webId] is the original input URL; including it in the message helps the
/// user identify which entry failed, which is especially helpful when
/// validating a list of WebIDs.

String? webIdCheckMessage(WebIdCheckResult result, {String webId = ''}) {
  switch (result.status) {
    case WebIdCheckStatus.valid:
      return null;

    case WebIdCheckStatus.notAbsoluteUrl:
      final urlPart = webId.isEmpty ? '' : ' "$webId"';
      return 'The WebID$urlPart is not a fully qualified URL. A WebID must '
          'start with `https://` and include a host (e.g. '
          'https://<their-pod>/profile/card#me).';

    case WebIdCheckStatus.invalidIpv4:
      return 'The host "${result.host}" looks like an IP address but is '
          'not a valid IPv4 literal. A valid IPv4 address has four octets '
          'separated by dots, each between 0 and 255 (e.g. 192.168.1.1).';

    case WebIdCheckStatus.unreachable:
      if (result.host.isEmpty) {
        final details =
            result.error != null ? '\n\nDetails: ${result.error}' : '';
        return 'Unable to reach the WebID server. '
            'Please check the URL and your network connection.$details';
      }
      if (isValidIpv4(result.host)) {
        return 'Unable to reach the IP address "${result.host}". '
            'The server may be offline, on a different network, or blocked '
            'by a firewall. Please check the address and your network '
            'connection.';
      }
      return 'Unable to resolve the domain "${result.host}". '
          'Please check the WebID URL and your network connection.';

    case WebIdCheckStatus.notProfile:
      final urlPart = webId.isEmpty ? 'The URL' : 'The URL "$webId"';
      return '$urlPart is reachable but does not point to a Solid WebID '
          'profile document. Make sure you are entering a WebID from a '
          'Solid POD (e.g. https://<their-pod>/profile/card#me), not the '
          'address of an ordinary website.';

    case WebIdCheckStatus.notExist:
      return 'This WebID does not exist. Please enter the correct WebID.';

    case WebIdCheckStatus.unknown:
      return 'Could not verify this WebID. The server returned an '
          'unexpected response. Please check the URL and try again.';
  }
}
