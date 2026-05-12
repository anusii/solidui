/// The primary App widget.
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
      home: const SolidLogin(
        title: 'SOLID POD DEMONSTRATOR',
        appDirectory: 'demopod',
        image: AssetImage('assets/images/demopod_image.jpg'),
        logo: AssetImage('assets/images/demopod_logo.png'),
        link: 'https://github.com/anusii/solidpod/blob/main/demopod/README.md',
        required: false,
        infoButtonStyle: InfoButtonStyle(
          tooltip: 'Visit the DemoPod documentation.',
        ),
        child: appScaffold,
      ),
    );
  }
}
