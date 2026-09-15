// Tests for the connection failure messages — telling the user whether the
// device is offline, the name could not be looked up, or the server is down.

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/utils/network_diagnosis.dart';

void main() {
  const server = 'https://pods.solidcommunity.au';

  group('connectionFailureMessage', () {
    test('keeps the caller lead sentence', () {
      final message = connectionFailureMessage(
        'Unable to authenticate with $server.',
        server,
        NetworkStatus.offline,
      );

      expect(message, startsWith('Unable to authenticate with $server.'));
    });

    test('offline names the network, not the server', () {
      final message = connectionFailureMessage(
        'Lead.',
        server,
        NetworkStatus.offline,
      );

      expect(message, contains('not connected to the internet'));
      expect(message, isNot(contains('pods.solidcommunity.au is')));
    });

    test('an unknown host blames the name, not the connection', () {
      final message = connectionFailureMessage(
        'Lead.',
        server,
        NetworkStatus.unknownHost,
      );

      expect(message, contains('internet is reachable'));
      expect(
        message,
        contains('server name pods.solidcommunity.au cannot be found'),
      );
    });

    test('unreachable blames the server', () {
      final message = connectionFailureMessage(
        'Lead.',
        server,
        NetworkStatus.unreachable,
      );

      expect(
        message,
        contains('pods.solidcommunity.au is not responding'),
      );
    });

    test('reachable rules the connection out', () {
      final message = connectionFailureMessage(
        'Lead.',
        server,
        NetworkStatus.reachable,
      );

      expect(message, contains('not a connection problem'));
    });

    test('unknown falls back to the generic wording', () {
      final message = connectionFailureMessage(
        'Lead.',
        server,
        NetworkStatus.unknown,
      );

      expect(message, 'Lead. The server may be inaccessible or down.');
    });

    test('a WebID reports the host, not the whole URL', () {
      final message = connectionFailureMessage(
        'Lead.',
        // 20260915 gjw Split the URL string to avoid a lychee attempt to test
        // the link.
        'https'
            '://someone.solidcommunity.au/profile/card#me',
        NetworkStatus.unreachable,
      );

      expect(message, contains('someone.solidcommunity.au is not responding'));
      expect(message, isNot(contains('profile/card')));
    });

    test('a bare host name is handled', () {
      final message = connectionFailureMessage(
        'Lead.',
        'pods.solidcommunity.au',
        NetworkStatus.unreachable,
      );

      expect(
        message,
        contains('pods.solidcommunity.au is not responding'),
      );
    });
  });

  group('diagnoseConnection', () {
    test('an unusable target cannot be diagnosed', () async {
      expect(await diagnoseConnection('   '), NetworkStatus.unknown);
    });

    test('a name that cannot be looked up is an unknown host, or offline',
        () async {
      // 20260915 gjw .invalid is reserved by RFC 2606 and never resolves. The
      // outcome depends on the machine running the test: with the internet up
      // this is an unknown host, and on a disconnected machine it is offline.

      final status = await diagnoseConnection('https://no.such.host.invalid');

      expect(
        status,
        anyOf(NetworkStatus.unknownHost, NetworkStatus.offline),
      );
    });

    test('a genuinely reachable host is reported reachable', () async {
      // 20260915 gjw Guards against a control-host-only reachability check:
      // this must come back reachable on its own, not merely because
      // 1.1.1.1/8.8.8.8 answered — those are not even consulted on this path.

      final status = await diagnoseConnection(server);

      expect(status, NetworkStatus.reachable);
    });
  });
}
