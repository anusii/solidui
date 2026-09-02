/// Server selector field for the Solid login screen.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/

library;

import 'package:flutter/material.dart';

import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solidui/src/widgets/solid_login_helper.dart';

/// Known public Solid Pod servers listed at solidproject.org/get_a_pod.
/// [pods.solidcommunity.au] is listed first and used as the default.

const List<String> kKnownSolidServers = [
  'https://pods.solidcommunity.au',
  'https://privatedatapod.com',
  'https://solidcommunity.net',
  'https://solidweb.me',
  'https://solidweb.org',
  'https://solidweb.app',
  'https://teamid.live',
  // 20260605 gjw SSL certificate expired. 'https' '://trinpod.eu',
  'https://trinpod.us',
  'https://igrant.io/datapod.html',
  'https://start.inrupt.com',
  'https://solid.redpencil.io',
];

const _kServerPrefKey = 'solidui_last_server';
const _kDefaultServer = 'https://pods.solidcommunity.au';

/// A [TextFormField] with a tappable dropdown of known public Solid servers.
///
/// The last-used server is persisted via [SharedPreferences] and pre-filled
/// on the next launch. The supplied [controller] is kept authoritative — no
/// secondary internal controller is created.

class SolidServerField extends StatefulWidget {
  final TextEditingController controller;
  final SolidLoginThemeMode themeMode;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  const SolidServerField({
    super.key,
    required this.controller,
    required this.themeMode,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  State<SolidServerField> createState() => _SolidServerFieldState();
}

class _SolidServerFieldState extends State<SolidServerField> {
  bool _dropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _loadSavedServer();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(SolidServerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      // SolidLogin creates a new TextEditingController on every build() call.
      // Re-wire the listener and restore the saved server into the new one.
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
      _loadSavedServer();
    }
  }

  void _onControllerChange() {
    // Rebuild so the filtered list updates as the user types.
    if (_dropdownOpen) setState(() {});
  }

  Future<void> _loadSavedServer() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kServerPrefKey);
    if (!mounted) return;
    if (saved != null) {
      // Always restore the user's last choice, overriding any widget default.
      widget.controller.text = saved;
    } else if (widget.controller.text.isEmpty) {
      // No saved value yet — use the built-in default.
      widget.controller.text = _kDefaultServer;
    }
  }

  Future<void> _saveServer(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kServerPrefKey, trimmed);
  }

  // The dropdown always shows the full list — filtering happens via the
  // inline text field autocomplete, not the dropdown menu.
  List<String> get _filteredServers => kKnownSolidServers;

  void _selectServer(String server) {
    widget.controller.text = server;
    _saveServer(server);
    setState(() => _dropdownOpen = false);
    // Do NOT call onFieldSubmitted — the user should explicitly tap Login
    // or press Enter to proceed. Just give focus back to the field so they
    // can review the selected server.
    widget.focusNode?.requestFocus();
  }

  /// Inline autocomplete: if what the user typed is a prefix of exactly one
  /// known server, complete the text and select the suffix so the user can
  /// keep typing or press Enter to accept.
  void _tryAutocomplete(String typed) {
    if (typed.isEmpty) return;
    final lower = typed.toLowerCase();
    final matches = kKnownSolidServers
        .where((s) => s.toLowerCase().startsWith(lower))
        .toList();
    if (matches.length != 1) return;
    final completion = matches.first;
    if (completion.toLowerCase() == lower) return; // already complete
    widget.controller.value = TextEditingValue(
      text: completion,
      selection: TextSelection(
        baseOffset: typed.length,
        extentOffset: completion.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeMode;
    final fieldStyle = TextStyle(color: theme.textColor, fontSize: 16);
    final labelStyle = TextStyle(color: theme.hintColor, fontSize: 16);
    final floatingStyle = TextStyle(color: theme.textColor);
    final borderSide = BorderSide(color: theme.inputBorderColor);
    final focusedBorder = BorderSide(color: theme.inputBorderColor, width: 2);
    final filtered = _filteredServers;

    return MarkdownTooltip(
      message: defaultServerTooltip,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: TextInputAction.go,
            style: fieldStyle,
            onChanged: (v) {
              _saveServer(v);
              _tryAutocomplete(v);
            },
            onFieldSubmitted: (v) {
              _saveServer(v);
              setState(() => _dropdownOpen = false);
              widget.onFieldSubmitted?.call(v);
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'Solid Server',
              labelStyle: labelStyle,
              floatingLabelStyle: floatingStyle,
              hintText: 'Solid server URL (or WebID)',
              hintStyle: labelStyle,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: UnderlineInputBorder(borderSide: borderSide),
              focusedBorder: UnderlineInputBorder(borderSide: focusedBorder),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
                child: Icon(
                  _dropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: theme.hintColor,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_dropdownOpen && filtered.isNotEmpty)
            Material(
              elevation: 4,
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(
                      filtered[i],
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textColor,
                      ),
                    ),
                    onTap: () => _selectServer(filtered[i]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
