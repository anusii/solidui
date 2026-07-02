/// A screen to demonstrate various capabilities of solidlogin.
///
// Time-stamp: <Wednesday 2025-09-17 08:23:30 +1000 Graham Williams>
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Zheyuan Xu, Anushka Vidanage, Kevin Wang, Dawei Chen, Graham Williams

// TODO 20240411 gjw EITHER REPAIR ALL CONTEXT ISSUES OR EXPLAIN WHY NOT?

// ignore_for_file: use_build_context_synchronously

library;

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart'
    show
        GrantPermissionUi,
        InitialSetupScreenBody,
        SharedResourcesUi,
        SolidScaffold,
        changeKeyPopup,
        changePasswordPopup,
        createAccountPopup,
        getKeyFromUserIfRequired,
        largeGapV,
        loginIfRequired,
        logoutPopup,
        smallGapV,
        solidLoginStatusNotifier;

import 'package:demopod/app.dart';
import 'package:demopod/constants/app.dart';
import 'package:demopod/dialogs/alert.dart';
import 'package:demopod/features/absolute_url_demo.dart';
import 'package:demopod/features/check_file_encryption.dart';
import 'package:demopod/features/create_acl_inherited_file.dart';
import 'package:demopod/features/edit_keyvalue.dart';
import 'package:demopod/features/file_service.dart';
import 'package:demopod/features/load_test.dart';
import 'package:demopod/features/manage_acl_folder.dart';
import 'package:demopod/features/multiple_resource_sharing.dart';
import 'package:demopod/features/permission_callback_demo.dart';
import 'package:demopod/features/read_acl_inherited_file.dart';
import 'package:demopod/features/view_keys.dart';
import 'package:demopod/utils/ensure_resource.dart';
import 'package:demopod/utils/rdf.dart';

/// A widget for the demonstration screen of the application.

class Home extends StatefulWidget {
  /// Initialise widget variables.

  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  String sampleText = '';

  // Step 1: Loading state variable.

  bool _isLoading = false;

  // Indicator for write encrypted/plaintext data

  bool _writeEncrypted = true;

  // The current webID

  String? _webId;

  @override
  void initState() {
    super.initState();

    solidLoginStatusNotifier.addListener(_onLoginStatusChanged);
  }

  @override
  void dispose() {
    solidLoginStatusNotifier.removeListener(_onLoginStatusChanged);
    super.dispose();
  }

  void _onLoginStatusChanged() {
    if (!mounted) return;
    setState(() {
      _webId = solidLoginStatusNotifier.webId;
    });
  }

  void _resetWebId() {
    setState(() {
      _webId = null;
    });
  }

  Future<void> _showPrivateData() async {
    setState(() {
      // Begin loading.

      _isLoading = true;
    });

    try {
      final fileContent = await readPod(
        await getEncKeyPath(),
        pathType: PathType.relativeToPod,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewKeys(
            keyInfo: fileContent,
            title: appTitle,
          ),
        ),
      );
    } on Exception catch (e) {
      debugPrint('Exception: $e');
    } finally {
      if (mounted) {
        setState(() {
          // End loading.

          _isLoading = false;
        });
      }
    }
  }

  Future<void> _readWritePrivateData() async {
    setState(() {
      // Begin loading.
      _isLoading = true;
    });

    final fileName = _writeEncrypted ? dataFile : dataFilePlain;

    List<({String key, dynamic value})>? pairs;

    try {
      final fileContent = await readPod(fileName);

      pairs = await parseTTLStr(fileContent);
    } on Exception catch (e) {
      debugPrint('Exception: $e');
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KeyValueEdit(
          title: 'Basic Key Value Editor',
          fileName: fileName,
          keyValuePairs: pairs,
          encrypted: _writeEncrypted,
          child: widget,
        ),
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _readMetaData() async {
    final fileName = _writeEncrypted ? dataFile : dataFilePlain;

    try {
      final fileMetadata = await readResMetadata(fileName);

      final dateFormatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss');

      showFileMetadataDialog(
        context: context,
        fileName: fileName,
        lastModified: dateFormatter.format(fileMetadata.lastModified),
        contentLength: fileMetadata.contentLength.toString(),
        contentType: fileMetadata.contentType,
        allowdAccess: fileMetadata.wacAllow,
      );
    } on Exception catch (e) {
      debugPrint('Exception: $e');
    }
  }

  // Helper method to demonstrate the security key prompt.

  Future<void> _showSecurityKeyPrompt() async {
    // First ensure we are logged in.

    final loggedIn = await loginIfRequired(
      clientId: clientIdVal,
      redirectUris: redirectUrisList,
      postLogoutRedirectUris: postLogoutRedirectUrisList,
      context: context,
    );

    if (loggedIn) {
      // Forget the security key to ensure the prompt appears.

      await KeyManager.forgetSecurityKey();

      // Inform user about what will happen next.

      await alert(
        context,
        'The security key has been forgotten locally. The next step will show the security key prompt which you would normally see when accessing secured data after logging in.',
      );

      // Directly show the security key prompt with WebID.

      try {
        // This will trigger the security key prompt since we've forgotten the key.

        await getKeyFromUserIfRequired(context, widget);

        // Only show this if the user enters the correct key.

        await alert(
          context,
          'Your security key was entered correctly and has been saved for this session.',
        );
      } catch (e) {
        debugPrint('Error: $e');
        await alert(context, 'Error or cancelled: $e');
      }
    }
  }

  void showFileMetadataDialog({
    required BuildContext context,
    required String fileName,
    required String contentLength,
    required String lastModified,
    required String contentType,
    required String allowdAccess,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('File Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('File name', fileName),
            _infoRow('Last modified', lastModified),
            _infoRow('Content length', contentLength),
            _infoRow('Content type', contentType),
            _infoRow('Allowed operations', allowdAccess),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showFetchNotificationsDialog() async {
    final loggedIn = await loginIfRequired(
      clientId: clientIdVal,
      redirectUris: redirectUrisList,
      postLogoutRedirectUris: postLogoutRedirectUrisList,
      context: context,
    );
    if (!loggedIn) return;

    await getKeyFromUserIfRequired(context, widget);

    List<PodNotification> notifications;
    try {
      notifications = await fetchNotifications();
    } on Exception catch (e) {
      debugPrint('fetchNotifications failed: $e');
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Fetch Failed'),
          content: Text('Could not fetch notifications:\n$e'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Notifications (${notifications.length})'),
          content: SizedBox(
            width: double.maxFinite,
            child: notifications.isEmpty
                ? const Text('No notifications yet.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      final dt = DateTime.fromMillisecondsSinceEpoch(
                        n.timestamp,
                      );
                      return ListTile(
                        dense: true,
                        title: Text(n.title),
                        subtitle: Text(
                          'From: ${n.senderWebId}\n'
                          'At: $dt\n'
                          'Priority: ${n.priority}'
                          '${n.content == null ? '' : '\n${n.content}'}',
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSendNotificationDialog() async {
    final loggedIn = await loginIfRequired(
      clientId: clientIdVal,
      redirectUris: redirectUrisList,
      postLogoutRedirectUris: postLogoutRedirectUrisList,
      context: context,
    );
    if (!loggedIn) return;

    final recipientController = TextEditingController();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    int selectedPriority = 1;
    String? recipientError;
    String? titleError;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, setDialogState) {
            return AlertDialog(
              title: const Text('Send Notification'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: recipientController,
                      decoration: InputDecoration(
                        labelText: 'Recipient WebID *',
                        errorText: recipientError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        errorText: titleError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content (optional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Low')),
                        DropdownMenuItem(value: 1, child: Text('Medium')),
                        DropdownMenuItem(value: 2, child: Text('High')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedPriority = value ?? 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final recipient = recipientController.text.trim();
                    final notifTitle = titleController.text.trim();

                    final hasErrors = recipient.isEmpty || notifTitle.isEmpty;

                    setDialogState(() {
                      recipientError = recipient.isEmpty
                          ? 'Recipient WebID is required'
                          : null;
                      titleError =
                          notifTitle.isEmpty ? 'Title is required' : null;
                    });

                    if (hasErrors) return;

                    Navigator.pop(dialogContext);

                    try {
                      await sendNotification(
                        recipientWebId: recipient,
                        title: notifTitle,
                        content: contentController.text.trim().isEmpty
                            ? null
                            : contentController.text.trim(),
                        priority: selectedPriority,
                      );

                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Success'),
                            content: const Text(
                              'Notification sent successfully.',
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } on RecipientNotReadyException catch (e) {
                      debugPrint('Recipient not ready: $e');
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Recipient Not Ready'),
                            content: Text(
                              'Could not send notification to $recipient.\n\n'
                              'The recipient may need to log in and update '
                              'their app setup in their Pod before you can '
                              'send notifications to them.\n\n'
                              'Details: $e',
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    } on Exception catch (e) {
                      debugPrint('Failed to send notification: $e');
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(
                              'Failed to send notification:\n$e',
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _sectionHeading(String title, {Widget? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing,
        ],
      ],
    );
  }

  Widget _buttonRow(List<Widget> buttons) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: buttons,
    );
  }

  Widget _buildContent(BuildContext context) {
    final dateStr = DateFormat('HH:mm:ss dd MMMM yyyy').format(DateTime.now());

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          smallGapV,
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: $dateStr',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _webId == null ? 'WebID: Not Logged In' : 'WebID: $_webId',
                  style: TextStyle(
                    color: _webId == null ? Colors.red : Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                largeGapV,

                // Pod Data File section with Encrypt Data toggle on the right.

                _sectionHeading(
                  'Pod Data File',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Encrypt Data?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _writeEncrypted,
                        onChanged: (val) {
                          setState(() {
                            _writeEncrypted = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    child: const Text('Read/Write Pod Data File'),
                    onPressed: () async {
                      await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      await _readWritePrivateData();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Read Metadata of Pod Data File'),
                    onPressed: () async {
                      await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      await _readMetaData();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        deleteDataFileDialog(dataFile, context);
                      }
                    },
                    child: const Text('Delete Pod Data File'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        await getKeyFromUserIfRequired(context, widget);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckFileEncryption(),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Check File Encryption'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        final webId = await getWebId();
                        setState(() {
                          _webId = webId;
                        });
                        await getKeyFromUserIfRequired(context, widget);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FileService(webId: webId!, child: widget),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Upload/Download Large File'),
                  ),

                  // Entry point to test read/write/delete using an
                  // absolute-URL path (PathType.absoluteUrl). It sits within
                  // this data upload/download section so that all of the core
                  // file operations live in one place.

                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        final webId = await getWebId();
                        setState(() {
                          _webId = webId;
                        });
                        await getKeyFromUserIfRequired(context, widget);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AbsoluteUrlDemo(),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Read/Write/Delete by Absolute URL'),
                  ),
                ]),

                largeGapV,

                // ACL Inheritance section.

                _sectionHeading('ACL Inheritance'),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        final webId = await getWebId();
                        setState(() {
                          _webId = webId;
                        });
                        await getKeyFromUserIfRequired(context, widget);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreateAclInheritedFile(),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Create Resource with ACL Inheritance'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        final webId = await getWebId();
                        setState(() {
                          _webId = webId;
                        });
                        await getKeyFromUserIfRequired(context, widget);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ReadAclInheritedFile(),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Read Resource with ACL Inheritance'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        final webId = await getWebId();
                        setState(() {
                          _webId = webId;
                        });
                        await getKeyFromUserIfRequired(context, widget);
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageAclFolder(),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Create/Delete a Folder with ACL'),
                  ),
                ]),

                largeGapV,

                // Notifications section.

                _sectionHeading('Notifications'),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    onPressed: _showSendNotificationDialog,
                    child: const Text('Send Notification'),
                  ),
                  ElevatedButton(
                    onPressed: _showFetchNotificationsDialog,
                    child: const Text('Fetch Notifications'),
                  ),
                ]),

                largeGapV,

                // Local Security Key Management section.

                _sectionHeading('Local Security Key Management'),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    child: const Text('Show Security Key (Encrypted)'),
                    onPressed: () async {
                      await _showPrivateData();
                    },
                  ),
                  ElevatedButton(
                    child: const Text(
                      'Show Security Key Prompt (For Demonstration)',
                    ),
                    onPressed: () async {
                      await _showSecurityKeyPrompt();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      changeKeyPopup(context, widget);
                    },
                    child: const Text('Change Security Key on Pod'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      changePasswordPopup(context, widget);
                    },
                    child: const Text('Change POD Password'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final serverUrl = _webId != null
                          ? Uri.parse(_webId!).origin
                          : 'https://pods.solidcommunity.au';
                      createAccountPopup(context, widget, serverUrl: serverUrl);
                    },
                    child: const Text('Create New Account'),
                  ),
                  ElevatedButton(
                    child: const Text('Forget Security Key Locally'),
                    onPressed: () async {
                      late String msg;
                      try {
                        await KeyManager.forgetSecurityKey();
                        msg = 'Successfully forgot local security key.';
                        _resetWebId();
                      } on Exception catch (e) {
                        msg = 'Failed to forget local security key: $e';
                      }
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Notice'),
                          content: Text(msg),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ]),

                largeGapV,

                // Solid Server Login Management section.

                _sectionHeading('Solid Server Login Management'),
                smallGapV,
                _buttonRow([
                  MarkdownTooltip(
                    message:
                        'This will remove from our local device\'s memory the '
                        'solid pod login information so that the next time you '
                        'start up the app you will need to login to your solid '
                        'server hosting your pod.',
                    child: ElevatedButton(
                      child: const Text('Forget Remote Solid Server Login'),
                      onPressed: () async {
                        final deleteRes = await deleteLogIn();

                        if (deleteRes) {
                          solidLoginStatusNotifier.markLoggedOut();
                        }

                        var deleteMsg = '';

                        if (deleteRes) {
                          deleteMsg =
                              'Successfully forgot remote solid server login info';
                        } else {
                          deleteMsg =
                              'Failed to forget login info. Try again in a while';
                        }

                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Notice'),
                            content: Text(deleteMsg),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );

                        _resetWebId();
                      },
                    ),
                  ),
                  MarkdownTooltip(
                    message:
                        'This will send a request through the browser to the '
                        'remote solid server to log you out of your Pod.',
                    child: ElevatedButton(
                      onPressed: () async {
                        await logoutPopup(context, const App());
                      },
                      child: const Text('Logout From Remote Solid Server'),
                    ),
                  ),
                  MarkdownTooltip(
                    message:
                        'Simulates the kind of *accidental* logout caused by '
                        'an expired or invalidated authentication token: the '
                        'local session is silently cleared without going '
                        'through the proper logout flow. Use this to verify '
                        'that the next action requiring authentication '
                        'reopens the login popup with your previous WebID '
                        'prefilled.',
                    child: ElevatedButton(
                      onPressed: () async {
                        // Silently drop the cached session to mimic a token
                        // that the server (or device storage) has invalidated
                        // behind the user's back.

                        final wasLoggedIn = await isUserLoggedIn();
                        await deleteLogIn();

                        solidLoginStatusNotifier.markLoggedOut();

                        if (!context.mounted) return;
                        _resetWebId();

                        await alert(
                          context,
                          wasLoggedIn
                              ? 'Authentication token invalidated. '
                                  'The next action that requires login should '
                                  'reopen the login popup with your previous '
                                  'WebID prefilled.'
                              : 'No active session was found, but any cached '
                                  'auth data has been cleared. Trigger a '
                                  'feature that requires login to see the '
                                  'login popup.',
                        );

                        if (!context.mounted) return;
                        await loginIfRequired(
                          clientId: clientIdVal,
                          redirectUris: redirectUrisList,
                          postLogoutRedirectUris: postLogoutRedirectUrisList,
                          context: context,
                        );
                      },
                      child: const Text('Simulate Token Invalidation'),
                    ),
                  ),
                ]),

                largeGapV,

                // Resource Permission Management section.

                _sectionHeading('Resource Permission Management'),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        await getKeyFromUserIfRequired(context, widget);

                        // Ensure the target resource exists on the Pod before
                        // opening the grant permission UI. The button
                        // previously failed with a "not found" error when
                        // keyvalue/key-value.ttl had never been created.

                        if (!context.mounted) return;
                        final ready = await ensurePodResourceExists(
                          context,
                          relativePath: dataFile,
                          defaultContent: createDemoTtlStr('key-value'),
                        );
                        if (!ready) return;

                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GrantPermissionUi(
                              backgroundColor: titleBackgroundColor,
                              resourceNames: [dataFile],
                              child: Home(),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add/Delete Permissions to a Specific Resource (key-value.ttl)',
                    ),
                  ),
                  ElevatedButton(
                    child: const Text('Permission Callback Demo'),
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        await getKeyFromUserIfRequired(context, widget);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PermissionCallbackDemo(
                              child: Home(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Add/Delete Permissions to any Resource'),
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        await getKeyFromUserIfRequired(context, widget);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GrantPermissionUi(
                              backgroundColor: titleBackgroundColor,
                              child: Home(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Share Multiple Specified Resources'),
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        await getKeyFromUserIfRequired(context, widget);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MultiResourceShareDemo(
                              child: Home(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ]),

                largeGapV,

                // Manage External Resources with Access section.

                _sectionHeading('Manage External Resources with Access'),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    child: const Text('View specific resource (key-value.ttl)'),
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        await getKeyFromUserIfRequired(context, widget);

                        // Ensure the target resource exists on the Pod before
                        // opening the shared resources UI. The button
                        // previously failed with a "not found" error when
                        // keyvalue/key-value.ttl had never been created.

                        if (!context.mounted) return;
                        final ready = await ensurePodResourceExists(
                          context,
                          relativePath: dataFile,
                          defaultContent: createDemoTtlStr('key-value'),
                        );
                        if (!ready) return;

                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SolidScaffold(
                              body: SharedResourcesUi(
                                backgroundColor: titleBackgroundColor,
                                fileName: 'key-value.ttl',
                                child: Home(),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    child: const Text(
                      'View ALL Resources your WebID has access to',
                    ),
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );
                      if (loggedIn) {
                        await getKeyFromUserIfRequired(context, widget);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SolidScaffold(
                              body: SharedResourcesUi(
                                backgroundColor: titleBackgroundColor,
                                child: Home(),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ]),

                largeGapV,

                // Setup Wizard Demo section.

                _sectionHeading('Setup Wizard Demo'),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await loginIfRequired(
                        clientId: clientIdVal,
                        redirectUris: redirectUrisList,
                        postLogoutRedirectUris: postLogoutRedirectUrisList,
                        context: context,
                      );

                      if (!loggedIn) {
                        debugPrint('Please login to run the demo');
                        return;
                      }

                      final webId = await getWebId();
                      if (webId == null) {
                        debugPrint('web ID is not available');
                        return;
                      }

                      final sampleDirUrl = await getDirUrl(
                        [
                          await getDataDirPath(),
                          'setup_wizard_demo',
                        ].join('/'),
                      );
                      final sampleFileName = 'setup_wizard_demo.ttl';
                      final sampleFileUrl = await getFileUrl(
                        [
                          await getDataDirPath(),
                          'sampleFileName',
                        ].join('/'),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SolidScaffold(
                            body: SafeArea(
                              child: InitialSetupScreenBody(
                                resNeedToCreate: {
                                  'folders': [sampleDirUrl],
                                  'files': [sampleFileUrl],
                                  'fileNames': [sampleFileName],
                                },
                                child: const Home(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Show Solid Pod Setup Wizard (Using Real Component)',
                    ),
                  ),
                ]),

                largeGapV,

                // Load Testing section. Drives the headless Python load tester
                // (loadtest/solid_load_test.py) so Pod hosting, login and
                // read/write access can be tested at scale (up to
                // ~100 concurrent users).

                _sectionHeading('Load Testing'),
                smallGapV,
                _buttonRow([
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoadTest(),
                        ),
                      );
                    },
                    child: const Text('Run Load Test'),
                  ),
                ]),

                smallGapV,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getWebId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _webId == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          _webId = snapshot.data;
        }

        return _buildContent(context);
      },
    );
  }
}
