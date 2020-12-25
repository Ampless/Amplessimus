#!/bin/sh
flutter channel master
flutter upgrade
flutter config --no-analytics
flutter pub get
dart run ci.dart
