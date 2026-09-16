/// Diagnose why a Solid server could not be reached.
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
/// Authors: Graham Williams

library;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:universal_io/io.dart'
    show InternetAddress, NetworkInterface, Socket;

/// How far we got when trying to reach a server.

enum NetworkStatus {
  /// The device has no network interface, or nothing on the internet can be
  /// reached from it.

  offline,

  /// The internet is reachable but the server name does not resolve.

  unknownHost,

  /// The name resolved but nothing accepted a connection.

  unreachable,

  /// The server accepted a connection, so the network is not the problem.

  reachable,

  /// Could not be determined (e.g. running in a browser).

  unknown,
}

/// How long each probe is given before it is treated as a failure.

const _probeTimeout = Duration(seconds: 5);

/// How long the internet-reachability probe is given. Shorter than
/// [_probeTimeout] because two hosts are tried in turn.

const _controlTimeout = Duration(seconds: 3);

/// Public DNS resolvers, as IP literals so that reaching them needs no name
/// lookup of its own. They are contacted only to tell "the internet is down"
/// apart from "that server name does not exist", and only after the login
/// itself has already failed. Two are tried because a network may block one.

const _controlHosts = ['1.1.1.1', '8.8.8.8'];

/// The port used for the internet-reachability probe. Both control hosts
/// serve DNS-over-HTTPS here, so a plain TCP connect is enough.

const _controlPort = 443;

/// Returns the URI for [target], which may be a server URL, a WebID, or a
/// bare host name. Returns null when no host can be extracted.

Uri? _uriOf(String target) {
  final trimmed = target.trim();
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.host.isNotEmpty) return uri;

  // 20260915 gjw No scheme, so Uri puts the host in the path. Retry as an
  // https URL.

  final withScheme = Uri.tryParse('https://$trimmed');
  if (withScheme != null && withScheme.host.isNotEmpty) return withScheme;

  return null;
}

/// Returns the host name of [target], or null when there is none.

String? _hostOf(String target) => _uriOf(target)?.host;

/// Reports whether the device has any non-loopback network interface. A
/// platform that cannot enumerate interfaces is treated as connected, so we
/// never tell the user they are offline on a guess.

Future<bool> _hasNetworkInterface() async {
  try {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
    ).timeout(_probeTimeout);

    return interfaces.isNotEmpty;
  } on Object {
    return true;
  }
}

/// Reports whether a TCP connection to [host] on [port] can be opened within
/// [timeout]. The connection is closed immediately; nothing is sent.

Future<bool> _canConnect(String host, int port, Duration timeout) async {
  try {
    final socket = await Socket.connect(host, port, timeout: timeout);
    socket.destroy();

    return true;
  } on Object {
    return false;
  }
}

/// Reports whether [host] resolves to an address.

Future<bool> _canResolve(String host) async {
  try {
    await InternetAddress.lookup(host).timeout(_probeTimeout);

    return true;
  } on Object {
    return false;
  }
}

/// Reports whether anything out on the internet can be reached. Uses the IP
/// literals in [_controlHosts] so the answer does not itself depend on name
/// resolution — that is what lets a dead connection be told apart from a
/// server name that does not exist.

Future<bool> _hasInternetAccess() async {
  for (final host in _controlHosts) {
    if (await _canConnect(host, _controlPort, _controlTimeout)) return true;
  }

  return false;
}

/// Probes the network to work out why [target] could not be reached.
///
/// Called on the failure path only, so the probes cost nothing during a
/// successful login.

Future<NetworkStatus> diagnoseConnection(String target) async {
  // 20260915 gjw A browser exposes neither interfaces nor raw sockets, so
  // there is nothing to probe.

  if (kIsWeb) return NetworkStatus.unknown;

  final uri = _uriOf(target);
  if (uri == null) return NetworkStatus.unknown;

  if (!await _hasNetworkInterface()) return NetworkStatus.offline;

  // 20260915 gjw A name that does not resolve means either the internet is
  // down or the server name is wrong. Probing a DNS-free control host tells
  // the two apart.

  if (!await _canResolve(uri.host)) {
    return (await _hasInternetAccess())
        ? NetworkStatus.unknownHost
        : NetworkStatus.offline;
  }

  final port = uri.hasPort ? uri.port : (uri.scheme == 'http' ? 80 : 443);

  if (await _canConnect(uri.host, port, _probeTimeout)) {
    return NetworkStatus.reachable;
  }

  // 20260915 gjw The name resolved, possibly from cache, yet nothing
  // answered. Confirm the internet is still up before blaming the server.

  return (await _hasInternetAccess())
      ? NetworkStatus.unreachable
      : NetworkStatus.offline;
}

/// Builds the user-facing message for a failed connection, combining the
/// caller's [lead] sentence with an explanation of [status] for [target].

String connectionFailureMessage(
  String lead,
  String target,
  NetworkStatus status,
) {
  final host = _hostOf(target) ?? target;

  final detail = switch (status) {
    NetworkStatus.offline =>
      'This device is not connected to the internet — check your Wi-Fi or '
          'cable and try again.',
    NetworkStatus.unknownHost =>
      'The internet is reachable but the server name $host cannot be found — '
          'check that the address is correct.',
    NetworkStatus.unreachable =>
      '$host is not responding — the server may be down, or blocked by a '
          'firewall.',
    NetworkStatus.reachable =>
      '$host is reachable, so this is not a connection problem — the server '
          'refused the request or the login was not completed.',
    NetworkStatus.unknown => 'The server may be inaccessible or down.',
  };

  return '$lead $detail';
}
