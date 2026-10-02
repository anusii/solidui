/// Configure the auth handler from the app's SolidLogin.
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

import 'package:solidui/src/handlers/solid_auth_handler.dart';
import 'package:solidui/src/widgets/solid_login.dart';

/// Hand [login]'s settings to [SolidAuthHandler], so that a re-login from
/// within the app uses the same configuration, button styles and theme.

void autoConfigureAuthHandler(SolidLogin login) {
  SolidAuthHandler.instance.autoConfigureFromLogin(
    title: login.title,
    appDirectory: login.appDirectory,
    webId: login.webID,
    image: login.image,
    logo: login.logo,
    link: login.link,
    child: login.child,
    loginButtonStyle: login.loginButtonStyle,
    continueButtonStyle: login.continueButtonStyle,
    registerButtonStyle: login.registerButtonStyle,
    infoButtonStyle: login.infoButtonStyle,
    changeKeyButtonStyle: login.changeKeyButtonStyle,
    themeConfig: login.themeConfig,
    snackbarConfig: login.snackbarConfig,
    required: login.required,
    clientId: login.clientId,
    redirectUris: login.redirectUris,
    postLogoutRedirectUris: login.postLogoutRedirectUris,
  );
}
