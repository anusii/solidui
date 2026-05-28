# SolidUI Change Log

Noted here are the high level changes for the package.

Guide: Each version update is recorded here with a short user-oriented
description of the update. Updates in the 0.0.n series are heading
toward a 0.1 release. The `[version timestamp user]` string is
utilised by the flutter version_widget package.

The package is available from
[pub.dev](https://pub.dev/packages/solidui).

[//]: # (Coding documentation is available from [solid community)

[//]: # (au]&#40;https://solidcommunity.au/docs/solidui&#41;)

## 0.4.0 Refine and Tune

+ Bug fix decrypting public file [0.3.57 tonypioneer]
+ Implement checking file encryption [0.3.56 20260527 tonypioneer]
+ Support file uploads in FileBrowser [0.3.55 20260526 tonypioneer]
+ Update SolidAnimationDialog from NotePod updates [0.3.54 20260526 tonypioneer]
+ Fix onReorderItem. Support shared pod name/avatar [0.3.53 20260526 tonypioneer]
+ Add README to and resize ABOUT dialog [0.3.52 20260526 gjw]
+ Simplify INDIVIDUAL PERMISSION interface [0.3.51 20260521 tonypioneer]
+ Remember last menu selected - optional [0.3.50 20260521 gjw]
+ Check web hosts in permission form [0.3.49 20260520 tonypioneer]
+ Update Try Another WebID workflow [0.3.48 20260520 tonypioneer]
+ Review and improve Not Logged In workflow [0.3.47 20260520 tonypioneer]
+ Bug fix when resource does not exist #21 [0.3.46 20260519 tonypioneer]
+ Attempt to suppress macOS char on typing disclosure #315 [0.3.45 20260518 gjw]
+ Bug fix override version widget colours [0.3.44 20260515 gjw]
+ Updated version widget dependency [0.3.43 20260512 gjw]
+ Support an UPDATE button when version is updated [0.3.42 20260510 tonypioneer]
+ Bug fix popup animation blocking return to screen [0.3.41 20260510 tonypioneer]
+ Permission flow - popup instead disappearing snack on fail [0.3.40 20260510 gjw]
+ Bug fix: missing menu after invite; overflow menu [0.3.39 20260509 tonypioneer]
+ Profile -> Settings/Logout. About -> Share/Feedback [0.3.38 20260505 tonypioneer]
+ Add button to share the app [0.3.37 20260505 tonypioneer]
+ Bug fix CHANGELOG colour choices [0.3.36 20260505 gjw]
+ Update SolidScaffold login/logout/profile defaults [0.3.35 20260501 gjw]
+ Bug fix Clear profile cache on logout [0.3.34 20260501 tonypioneer]
+ Bug fix App blanks on login CANCEL [0.3.33 20260501 tonypioneer]
+ Prefill with webID on auth key timeout relogin [0.3.32 20260501 tonypioneer]
+ Add dropdown server list for SolidLogin [0.3.31 20260501 gjw]
+ Add is_desktop() util [0.3.30 20260430 gjw]
+ Do not word wrap ABOUT text [0.3.29 20260429 gjw]
+ Sort permission history recent first [0.3.28 20260429 jesscmoore]
+ Fix demo and sharing when resource not exist [0.3.27 20260426 jesscmoore]
+ Pod structure change => different security key prompt [0.3.26 20260429 tonypioneer]
+ Pop down SECURITY KEY after changng the key [0.3.25 20260429 tonypioneer]
+ Improve logout message [0.3.24 20260424 tonypioneer]
+ onLogout callback for memory clearance [0.3.23 20260424 tonypioneer]
+ Support multi sharing [0.3.22 20260423 jesscmoore]
+ Support user profiles [0.3.21 20260421 tonypioneer]
+ Review and cleanup [0.3.20 20260420 gjw]
+ Updated tooltip style to be consistent [0.3.19 20260420 gjw]
+ Fix overflow in appbar preferences [0.3.18 20260415 tonypioneer]
+ Add a Wrap() to avoid overflow on SolidLogin [0.3.18 20260410 gjw]
+ Place ABOUT button to right most by default [0.3.17 20260410 gjw]
+ Add missing wordWrap function [0.3.16 20260410 gjw]
+ Add showLogin to support no login button [0.3.15 20260410 gjw]
+ Support invisible LOGIN/CONTINUE buttons [0.3.14 20260409 gjw]
+ Support invisible REGISTER/INFO buttons for SolidLogin [0.3.13 20260409 gjw]
+ Retain app theme across restart [0.3.12 20260409 gjw]
+ Add get key if required to login [0.3.11 20260406 tonypioneer]
+ Fine tune UX for SolidScaffold elements [0.3.10 20260406 gjw]
+ List files/folder count in FileBrowser, not just file count [0.3.9 20260402 gjw]
+ Add keep login and other webid to SolidLogin() [0.3.8 20260326 tonypioneer]
+ Adds additional layout width checks [0.3.7 20260326 tonypioneer]
+ Add Security Key and Logged In to Nav menu [0.3.6 20260326 tonypioneer]
+ Add checkbox and new webid widgets to SolidLogin() [0.3.5 20260325 tonypioneer]
+ Add WebID to SetupWizard [0.3.4 20260325 tonypioneer]
+ Login again if webid changed [0.3.3 20260319 tonypioneer]
+ Fixed locmax issue with GrantPermissionUi [0.3.2 20260318 tonypioneer]
+ Bug fix notification of uninitialised pod [0.3.2 20260318 tonypioneer]
+ Bug fix to support SolidScaffold(showLogout:) [0.3.1 20260318 tonypioneer]

## 0.3.0 Stabilise

+ Publish to pub.dev [0.3.0 20260316 gjw]
+ Optimise pod initialisation check [0.2.2 20260219 tonypioneer]
+ Update SolidFile browser UI and functionals [0.2.1 20260219 tonypioneer]
+ Migrate remaining UI from solidpod to solidui [0.2.0 20260213 tonypioneer]

## 0.2.0 Complete UI Migration

+ Support delete file by url [0.1.5 20260206 dc]
+ Remove overflow on narrow and short login window [0.1.4 20260205 tonypioneer]
+ Added new spacing constants [0.1.3 20260204 jesscmoore]
+ Login warn if trying to set security key [0.1.2 20260204 tonypioneer]
+ Add theme button the security key options [0.1.1 20260204 tonypioneer]
+ Migrate Security Key and Permission GUI from solidpod [0.1.0 20260203 tonypioneer]

## 0.1.0 First Beta Release

+ Support dark mode for security key UI [0.0.34 20260130 tonypioneer]
+ Update security key workflows [0.0.33 20260130 tonypioneer]
+ Update dependency for file_picker 10.3.9 [0.0.32 20260127 dc]
+ UX review and remove duplicated login/logout [0.0.31 20260123 tonypioneer]
+ Improved setup wizard UX [0.0.30 20260123 tonypioneer]
+ Bug fix missing logout button [0.0.29 20260122 tonypioneer]
+ Improved SETUP WIZARD for better UX [0.0.28 20260122 tonypioneer]
+ Improve handling of app logo and image [0.0.27 20260122 tonypioneer]
+ Move PREFERENCES into the ABOUT dialog [0.0.26 20260122 tonypioneer]
+ Simplified light/dark theme management [0.0.25 20260116 tonypioneer]
+ Support custom folder structure [0.0.24 20260114 anusavid]
+ Default keyboard focus on LOGIN #160 [0.0.23 20260113 tonypioneer]
+ Updated solidpod dependency - writePod() #155 [0.0.22 20260113 dc]
+ Fixed page reload behaviour #158 [0.0.21 20260108 tonypioneer]
+ Drop basePath: requirement from SolidFile() [0.0.20 20260107 tonypioneer]
+ Improve theme and appbar button preferences [0.0.19 20251219 tonypioneer]
+ Added version userTextStyle for accessibility [0.0.18 20251612 tonypioneer]
+ On startup match THEME with system theme [0.0.17 20251212 tonypioneer]
+ Bug fix for LOADING icon background [0.0.16 20251212 tonypioneer]
+ Add LOGOUT to toolbar [0.0.15 20251212 tonypioneer]
+ Option to hide menu rail [0.0.14 20251210 gjw]
+ Updated dependencies [0.0.13 20251206 gjw]
+ Support navigation to subpages [0.0.12 20251202 tonypioneer]
+ readPod improvements for resource handling [0.0.11 20251202 tonypioneer]
+ Update to flutter_markdown_plus [0.0.10 20251124 gjw]
+ Updated readPod and writePod [0.0.9 20251123 cdawei]
+ Show username in status bar uri [0.0.8 20251030 tonypioneer]
+ Remove solidui/solidpod circular dependency [0.0.7 20251029 tonypioneer]
+ Refactor SolidLogin for max 300 loc lint [0.0.6 20251017 cdawei]
+ Fix security key handling [0.0.5 20251027 tonypioneer]
+ Add webid to an info header in navdrawer [0.0.4 20251017 tonypioneer]
+ Update version widget dependency [0.0.3 20251008 gjw]
+ EXAMPLE: Add demo of getting version [0.0.2 20250820 gjw]
+ CHANGELOG: Initial release [0.0.1 20250819 tonypioneer]
