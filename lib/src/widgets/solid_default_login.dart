/// Default Solid Login Widget.
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
/// Authors: Tony Chen

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:solidui/src/widgets/solid_login.dart';

/// Default login widget for Solid POD authentication.

class SolidDefaultLogin extends StatefulWidget {
  /// The application title.

  final String appTitle;

  /// The application directory for POD storage.

  final String appDirectory;

  /// The default server URL for authentication.

  final String defaultServerUrl;

  /// The application image.

  final AssetImage? appImage;

  /// The application logo.

  final AssetImage? appLogo;

  /// The application link.

  final String? appLink;

  /// Widget to navigate to after successful login.

  final Widget? loginSuccessWidget;

  const SolidDefaultLogin({
    super.key,
    required this.appTitle,
    required this.appDirectory,
    required this.defaultServerUrl,
    this.appImage,
    this.appLogo,
    this.appLink,
    this.loginSuccessWidget,
  });

  @override
  State<SolidDefaultLogin> createState() => _SolidDefaultLoginState();
}

class _SolidDefaultLoginState extends State<SolidDefaultLogin> {
  /// The resolved application image after checking available assets.

  AssetImage? _resolvedImage;

  /// The resolved application logo after checking available assets.

  AssetImage? _resolvedLogo;

  /// Whether asset resolution has completed.

  bool _assetsResolved = false;

  /// Default image from solidui package.

  static const AssetImage _soliduiDefaultImage = AssetImage(
    'assets/images/app_image.jpg',
    package: 'solidui',
  );

  /// Default logo from solidui package.

  static const AssetImage _soliduiDefaultLogo = AssetImage(
    'assets/images/app_icon.png',
    package: 'solidui',
  );

  @override
  void initState() {
    super.initState();
    _resolveAssets();
  }

  /// Resolves the appropriate assets to use.

  Future<void> _resolveAssets() async {
    if (widget.appImage != null) {
      _resolvedImage = await _resolveAssetWithFallbackFromPath(
        widget.appImage!,
        _soliduiDefaultImage,
      );
    } else {
      _resolvedImage = await _resolveAssetWithFallback(
        'app_image',
        _soliduiDefaultImage,
      );
    }

    if (widget.appLogo != null) {
      _resolvedLogo = await _resolveAssetWithFallbackFromPath(
        widget.appLogo!,
        _soliduiDefaultLogo,
      );
    } else {
      _resolvedLogo = await _resolveAssetWithFallback(
        'app_icon',
        _soliduiDefaultLogo,
      );
    }

    if (mounted) {
      setState(() {
        _assetsResolved = true;
      });
    }
  }

  /// Attempts to resolve an asset from user-specified path with fallback.
  ///
  /// Returns the first available asset in this order:
  /// 1. The requested asset if it exists
  /// 2. Same file name with alternate extension (png->jpg or jpg->png)
  /// 3. The solidui package default

  Future<AssetImage> _resolveAssetWithFallbackFromPath(
    AssetImage requestedAsset,
    AssetImage fallbackDefault,
  ) async {
    final requestedPath = requestedAsset.assetName;

    // First, try the user-specified asset.

    if (await _assetExists(requestedPath)) {
      return requestedAsset;
    }

    // Extract base name and extension from the requested asset path.

    final baseName = _extractBaseName(requestedPath);
    final extension = _extractExtension(requestedPath);
    final directory = _extractDirectory(requestedPath);

    // Try alternate extension: if original is .png try .jpg, and vice versa.

    final alternateExtension = extension.toLowerCase() == 'png' ? 'jpg' : 'png';
    final alternatePath = '$directory$baseName.$alternateExtension';
    if (await _assetExists(alternatePath)) {
      return AssetImage(alternatePath);
    }

    // Fall back to solidui default.

    return fallbackDefault;
  }

  /// Attempts to resolve an asset by checking png and jpg formats.
  ///
  /// Returns the first available asset or the fallback default.
  /// [baseName] is the asset name without extension (e.g., 'app_image').
  /// [fallbackDefault] is the default asset to use if neither format exists.

  Future<AssetImage> _resolveAssetWithFallback(
    String baseName,
    AssetImage fallbackDefault,
  ) async {
    // Check for .png format first.

    final pngPath = 'assets/images/$baseName.png';
    if (await _assetExists(pngPath)) {
      return AssetImage(pngPath);
    }

    // Check for .jpg format.

    final jpgPath = 'assets/images/$baseName.jpg';
    if (await _assetExists(jpgPath)) {
      return AssetImage(jpgPath);
    }

    // Fall back to solidui default.

    return fallbackDefault;
  }

  /// Extracts the directory path from an asset path.
  ///
  /// For example, 'assets/images/app_image.png' returns 'assets/images/'.

  String _extractDirectory(String path) {
    final lastSlash = path.lastIndexOf('/');
    return lastSlash != -1 ? path.substring(0, lastSlash + 1) : '';
  }

  /// Extracts the file extension from an asset path.
  ///
  /// For example, 'assets/images/app_image.png' returns 'png'.

  String _extractExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    return dotIndex != -1 ? path.substring(dotIndex + 1) : '';
  }

  /// Extracts the base name (without extension) from an asset path.
  ///
  /// For example, 'assets/images/app_image.png' returns 'app_image'.

  String _extractBaseName(String path) {
    final fileName = path.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
  }

  /// Checks whether an asset exists in the asset bundle.
  ///
  /// Returns true if the asset can be loaded, false otherwise.

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator whilst assets are being resolved.

    if (!_assetsResolved) {
      return Theme(
        data: Theme.of(context).brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        child: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).brightness == Brightness.dark
          ? ThemeData.dark()
          : ThemeData.light(),
      child: SolidLogin(
        required: false,
        title: widget.appTitle,
        appDirectory: widget.appDirectory,
        webID: widget.defaultServerUrl,
        image: _resolvedImage ?? _soliduiDefaultImage,
        logo: _resolvedLogo ?? _soliduiDefaultLogo,
        link: widget.appLink ?? '',
        child:
            widget.loginSuccessWidget ?? _getDefaultSuccessWidget(context),
      ),
    );
  }

  /// Get default success widget if none provided.

  Widget _getDefaultSuccessWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Successfully logged in!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to ${widget.appTitle}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate back or to main app.

                Navigator.pop(context);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
