# SolidUI Change Log

Noted here are the high level changes for the package.

Guide: Each version update is recorded here with a short user-oriented
description of the update. Updates in the 0.0.n series are heading
toward a 0.1 release. The `[version timestamp user]` string is
utilised by the flutter version_widget package.

The package is available from
[pub.dev](https://pub.dev/packages/solidui).

Coding documentation is available from [solid community
au](https://solidcommunity.au/docs/solidui)

## 0.4.0 Refine and Tune

+ Improve logout message [0.3.24 20260424 tchen]
+ onLogout callback for memory clearance [0.3.23 20260424 tchen]
+ Support multi sharing [0.3.22 20260423 jesscmoore]
+ Support user profiles [0.3.21 20260421 tchen]
+ Review and cleanup [0.3.20 20260420 gjw]
+ Updated tooltip style to be consistent [0.3.19 20260420 gjw]
+ Fix overflow in appbar preferences [0.3.18 20260415 tchen]
+ Add a Wrap() to avoid overflow on SolidLogin [0.3.18 20260410 gjw]
+ Place ABOUT button to right most by default [0.3.17 20260410 gjw]
+ Add missing wordWrap function [0.3.16 20260410 gjw]
+ Add showLogin to support no login button [0.3.15 20260410 gjw]
+ Support invisible LOGIN/CONTINUE buttons [0.3.14 20260409 gjw]
+ Support invisible REGISTER/INFO buttons for SolidLogin [0.3.13 20260409 gjw]
+ Retain app theme across restart [0.3.12 20260409 gjw]
+ Add get key if required to login [0.3.11 20260406 tchen]
+ Fine tune UX for SolidScaffold elements [0.3.10 20260406 gjw]
+ List files/folder count in FileBrowser, not just file count [0.3.9 20260402 gjw]
+ Add keep login and other webid to SolidLogin() [0.3.8 20260326 tchen]
+ Adds additional layout width checks [0.3.7 20260326 tchen]
+ Add Security Key and Logged In to Nav menu [0.3.6 20260326 tchen]
+ Add checkbox and new webid widgets to SolidLogin() [0.3.5 20260325 tchen]
+ Add WebID to SetupWizard [0.3.4 20260325 tchen]
+ Login again if webid changed [0.3.3 20260319 tchen]
+ Fixed locmax issue with GrantPermissionUi [0.3.2 20260318 tchen]
+ Bug fix notification of uninitialised pod [0.3.2 20260318 tchen]
+ Bug fix to support SolidScaffold(showLogout:) [0.3.1 20260318 tchen]

## 0.3.0 Stabilise

+ Publish to pub.dev [0.3.0 20260316 gjw]
+ Optimise pod initialisation check [0.2.2 20260219 tchen]
+ Update SolidFile browser UI and functionals [0.2.1 20260219 tchen]
+ Migrate remaining UI from solidpod to solidui [0.2.0 20260213 tchen]

## 0.2.0 Complete UI Migration

+ Support delete file by url [0.1.5 20260206 dc]
+ Remove overflow on narrow and short login window [0.1.4 20260205 tchen]
+ Added new spacing constants [0.1.3 20260204 jesscmoore]
+ Login warn if trying to set security key [0.1.2 20260204 tchen]
+ Add theme button the security key options [0.1.1 20260204 tchen]
+ Migrate Security Key and Permission GUI from solidpod [0.1.0 20260203 tchen]

## 0.1.0 First Beta Release

+ Support dark mode for security key UI [0.0.34 20260130 tchen]
+ Update security key workflows [0.0.33 20260130 tchen]
+ Update dependency for file_picker 10.3.9 [0.0.32 20260127 dc]
+ UX review and remove duplicated login/logout [0.0.31 20260123 tchen]
+ Improved setup wizard UX [0.0.30 20260123 tchen]
+ Bug fix missing logout button [0.0.29 20260122 tchen]
+ Improved SETUP WIZARD for better UX [0.0.28 20260122 tchen]
+ Improve handling of app logo and image [0.0.27 20260122 tchen]
+ Move PREFERENCES into the ABOUT dialog [0.0.26 20260122 tchen]
+ Simplified light/dark theme management [0.0.25 20260116 tchen]
+ Support custom folder structure [0.0.24 20260114 anusavid]
+ Default keyboard focus on LOGIN #160 [0.0.23 20260113 tchen]
+ Updated solidpod dependency - writePod() #155 [0.0.22 20260113 dc]
+ Fixed page reload behaviour #158 [0.0.21 20260108 tchen]
+ Drop basePath: requirement from SolidFile() [0.0.20 20260107 tchen]
+ Improve theme and appbar button preferences [0.0.19 20251219 tchen]
+ Added version userTextStyle for accessibility [0.0.18 20251612 tchen]
+ On startup match THEME with system theme [0.0.17 20251212 tchen]
+ Bug fix for LOADING icon background [0.0.16 20251212 tchen]
+ Add LOGOUT to toolbar [0.0.15 20251212 tchen]
+ Option to hide menu rail [0.0.14 20251210 gjw]
+ Updated dependencies [0.0.13 20251206 gjw]
+ Support navigation to subpages [0.0.12 20251202 tchen]
+ readPod improvements for resource handling [0.0.11 20251202 tchen]
+ Update to flutter_markdown_plus [0.0.10 20251124 gjw]
+ Updated readPod and writePod [0.0.9 20251123 cdawei]
+ Show username in status bar uri [0.0.8 20251030 tchen]
+ Remove solidui/solidpod circular dependency [0.0.7 20251029 tchen]
+ Refactor SolidLogin for max 300 loc lint [0.0.6 20251017 cdawei]
+ Fix security key handling [0.0.5 20251027 tchen]
+ Add webid to an info header in navdrawer [0.0.4 20251017 tchen]
+ Update version widget dependency [0.0.3 20251008 gjw]
+ EXAMPLE: Add demo of getting version [0.0.2 20250820 gjw]
+ CHANGELOG: Initial release [0.0.1 20250819 tchen]
