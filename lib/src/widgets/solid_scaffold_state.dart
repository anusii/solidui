/// Solid Scaffold State - State class for SolidScaffold.
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

// ignore_for_file: public_member_api_docs

part of 'solid_scaffold.dart';

class SolidScaffoldState extends State<SolidScaffold> {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SolidSecurityKeyService? _securityKeyService;
  SolidScaffoldSecurityKeyHelper? _securityKeyHelper;
  bool _isKeySaved = false;
  String? _appVersion, _currentWebId;
  bool _isVersionLoaded = false;
  bool? _cachedUsesInternalManagement;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initSecurityKey();
    if (SolidScaffoldInitHelpers.hasVersionConfig(widget.appBar)) {
      _loadAppVersion();
    }
    _initializeNotifiers();
    _setupListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.statusBar?.securityKeyStatus != null) {
        securityKeyNotifier.refreshStatus();
      }
    });
    _loadCurrentWebId();
  }

  void _initSecurityKey() {
    _securityKeyService = SolidScaffoldInitHelpers.initializeSecurityKeyService(
      widget.statusBar?.securityKeyStatus != null,
      _onSecurityKeyChanged,
      () => _securityKeyHelper?.loadStatus(
        widget.statusBar?.securityKeyStatus?.onKeyStatusChanged,
      ),
    );
    _securityKeyHelper = SolidScaffoldSecurityKeyHelper(
      securityKeyService: _securityKeyService,
      onStatusChanged: (s) => setState(() => _isKeySaved = s),
      isMounted: () => mounted,
    );
  }

  void _setupListeners() {
    if (widget.statusBar?.securityKeyStatus != null) {
      securityKeyNotifier.addListener(_onSecurityKeyNotifierChanged);
      _isKeySaved = securityKeyNotifier.isKeySaved;
    }
    solidPreferencesNotifier.addListener(_onPreferencesChanged);
    widget.controller?.addListener(_onControllerChanged);
  }

  Future<void> _initializeNotifiers() async {
    await SolidScaffoldInitHelpers.initializeThemeNotifier(
      _getUsesInternalManagement(),
      _onThemeChanged,
    );
    if (mounted) setState(() {});
  }

  Future<void> _loadCurrentWebId() async {
    final webId = await SolidScaffoldWebIdHelper.loadCurrentWebId(
      isMounted: () => mounted,
      currentWebId: _currentWebId,
    );
    if (mounted && webId != _currentWebId) {
      setState(() => _currentWebId = webId);
    }
  }

  @override
  void dispose() {
    _securityKeyService?.removeListener(_onSecurityKeyChanged);
    if (_getUsesInternalManagement()) {
      solidThemeNotifier.removeListener(_onThemeChanged);
    }
    if (widget.statusBar?.securityKeyStatus != null) {
      securityKeyNotifier.removeListener(_onSecurityKeyNotifierChanged);
    }
    solidPreferencesNotifier.removeListener(_onPreferencesChanged);
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  // Deferred to avoid triggering setState while the framework is building
  // widgets (e.g. when initializeIfNeeded updates the notifier during build).

  void _onPreferencesChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }
  void _onControllerChanged() => mounted ? setState(() {}) : null;
  void _onThemeChanged() => mounted ? setState(() {}) : null;

  void _onSecurityKeyNotifierChanged() {
    if (!mounted) return;
    final newStatus = securityKeyNotifier.isKeySaved;
    if (_isKeySaved != newStatus) {
      setState(() => _isKeySaved = newStatus);
      widget.statusBar?.securityKeyStatus?.onKeyStatusChanged?.call(newStatus);
    }
  }

  void _onSecurityKeyChanged() => _securityKeyHelper?.updateStatusFromService(
        widget.statusBar?.securityKeyStatus?.onKeyStatusChanged,
      );

  Future<void> refreshSecurityKeyStatus() async =>
      await _securityKeyHelper?.refresh(
        _isKeySaved,
        widget.statusBar?.securityKeyStatus?.onKeyStatusChanged,
      );

  String _getVersionToDisplay() =>
      SolidScaffoldHelpers.getVersionToDisplay(_isVersionLoaded, _appVersion);
  bool _shouldShowVersion() =>
      SolidScaffoldHelpers.shouldShowVersion(_isVersionLoaded);

  Future<void> _loadAppVersion() async {
    final version = await SolidScaffoldInitHelpers.loadAppVersion(true);
    if (mounted) {
      setState(() {
        _appVersion = version;
        _isVersionLoaded = true;
      });
    }
  }

  void _onMenuSelected(int index) {
    if (widget.controller?.hasSubpage ?? false) {
      widget.controller!.clearSubpage();
    }
    if (widget.bodyOverride != null) widget.onClearBodyOverride?.call();
    if (widget.onMenuSelected != null) {
      widget.onMenuSelected!(index);
    } else {
      setState(() => _selectedIndex = index);
    }
    if (widget.menu != null && index < widget.menu!.length) {
      widget.menu![index].onTap?.call(context);
    }
  }

  bool _isNarrowScreen(BoxConstraints constraints) {
    return widget.hideNavRail ||
        SolidScaffoldHelpers.isNarrowScreen(
          constraints,
          narrowThreshold: widget.narrowScreenThreshold,
        ) ||
        SolidScaffoldHelpers.isVeryNarrowScreen(constraints);
  }

  bool _getUsesInternalManagement() => _cachedUsesInternalManagement ??=
      SolidScaffoldHelpers.getUsesInternalManagement(widget.themeToggle);

  int? get _currentSelectedIndex {
    final subpage = widget.controller?.rawSubpage;
    if (subpage != null && widget.menu != null) {
      final idx = SolidScaffoldHelpers.findMatchingMenuIndex(
        subpage,
        widget.menu,
      );
      return idx;
    }
    return widget.selectedIndex ?? _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = _isNarrowScreen(constraints);
        final isCompat = widget.menu == null;
        final bodyContent = isCompat
            ? widget.body
            : SolidScaffoldLayoutBuilder.buildBody(
                context,
                !isNarrow,
                SolidScaffoldHelpers.convertToNavTabs(widget.menu),
                _currentSelectedIndex,
                SolidScaffoldHelpers.getEffectiveChild(
                  widget.menu,
                  _currentSelectedIndex,
                  widget.child,
                  widget.body,
                  widget.bodyOverride ?? widget.controller?.currentSubpage,
                ),
                _onMenuSelected,
                widget.onShowAlert,
              );

        return NotificationListener<SecurityKeyStatusChangedNotification>(
          onNotification: (n) {
            Future.delayed(const Duration(milliseconds: 300), () {
              securityKeyNotifier.refreshStatus();
              _loadCurrentWebId();
            });
            return true;
          },
          child: SolidScaffoldWidgetBuilder.buildFromWidget(
            context: context,
            constraints: constraints,
            scaffoldKey: _scaffoldKey,
            widget: widget,
            isWideScreen: !isNarrow,
            isCompatibilityMode: isCompat,
            bodyContent: bodyContent,
            isKeySaved: _isKeySaved,
            currentSelectedIndex: _currentSelectedIndex,
            onMenuSelected: _onMenuSelected,
            getUsesInternalManagement: _getUsesInternalManagement,
            shouldShowVersion: _shouldShowVersion,
            getVersionToDisplay: _getVersionToDisplay,
            currentWebId: _currentWebId,
          ),
        );
      },
    );
  }
}
