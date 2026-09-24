/// Tests for recognising snap confinement refusing the keyring.
///
/// Copyright (C) 2026, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:solidui/src/widgets/solid_login_actions.dart';

/// The real message, from radiopod 1.1.6 installed as a strictly confined
/// snap with password-manager-service not connected. Abridged only in the
/// middle; both markers the rule looks for are kept.

const _snapDenial =
    'PlatformException(Libsecret error, secret_service_get_sync: An AppArmor '
    'policy prevents this sender from sending this message to this recipient; '
    'type="method_call", sender=":1.1578" (uid=1000 pid=908939 '
    'comm="/snap/radiopod/x1/radiopod" label="snap.radiopod.radiopod '
    '(enforce)") interface="org.freedesktop.Secret.Service" '
    'member="OpenSession", null, null)';

void main() {
  group('isSnapKeyringDenial', () {
    test('recognises the real snap denial', () {
      expect(
        SolidLoginActions.isSnapKeyringDenial(_snapDenial, 'radiopod'),
        isTrue,
      );
    });

    test('is false when not running inside a snap', () {
      // A deb or source build can produce an AppArmor denial of its own, and
      // `snap connect` would be meaningless advice there.

      expect(SolidLoginActions.isSnapKeyringDenial(_snapDenial, null), isFalse);
    });

    test('is false for an empty snap name', () {
      // SNAP_NAME present but empty would otherwise build the nonsense
      // command "sudo snap connect :password-manager-service".

      expect(SolidLoginActions.isSnapKeyringDenial(_snapDenial, ''), isFalse);
    });

    test('a locked keyring inside a snap is NOT this', () {
      // Different cause, different remedy: the keyring advice should win.

      const locked =
          'PlatformException(Libsecret error, KeyringLocked: the keyring is '
          'locked, null, null)';

      expect(
        SolidLoginActions.isSnapKeyringDenial(locked, 'radiopod'),
        isFalse,
      );
    });

    test('an AppArmor denial about something else is NOT this', () {
      // Connecting password-manager-service would not help, so the raw error
      // is the honest thing to show.

      const other =
          'PlatformException(An AppArmor policy prevents this sender from '
          'sending this message to this recipient; '
          'interface="org.freedesktop.Notifications", null, null)';

      expect(SolidLoginActions.isSnapKeyringDenial(other, 'radiopod'), isFalse);
    });

    test('a secret-service error with no AppArmor denial is NOT this', () {
      // The service can fail for ordinary reasons — no daemon running, for
      // one — which confinement has nothing to do with.

      const noDaemon =
          'PlatformException(Libsecret error, secret_service_get_sync: '
          'org.freedesktop.Secret.Service not provided by any .service '
          'files, null, null)';

      expect(
        SolidLoginActions.isSnapKeyringDenial(noDaemon, 'radiopod'),
        isFalse,
      );
    });
  });
}
