/// The primary App widget.
///
/// Copyright (C) 2024, Software Innovation Institute, ANU.
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

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:demopod/app_scaffold.dart';
import 'package:demopod/constants/app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidThemeApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF0E4D7),
        ),
        useMaterial3: true,
      ),
      home: SolidLogin(
        // Images generated using Bing Image Creator from Designer, powered by
        // DALL-E3.

        title: 'SOLID UI DEMONSTRATOR',
        appDirectory: 'demopod',
        image: AssetImage('assets/images/demopod_image.png'),
        logo: AssetImage('assets/images/demopod_logo.png'),
        link: 'https://github.com/anusii/solidpod/blob/main/demopod/README.md',
        required: false,
        infoButtonStyle: InfoButtonStyle(
          tooltip: 'Visit the DemoPod documentation.',
        ),
        clientId: clientIdVal,
        // Use the following schemas depending on the platform
        //  Web: https://anushkavidanage.github.io/solidpod/example/redirect.html
        //  Mobile: com.example.demopod://redirect
        //  Desktop: http://localhost:4400/redirect
        //    (can use any port as long as it matches with the one in your id document)
        redirectUris: redirectUrisList,
        postLogoutRedirectUris: postLogoutRedirectUrisList,
        autoLogin: true,
        child: appScaffold,
      ),
    );
  }
}
