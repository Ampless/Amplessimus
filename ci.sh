#!/bin/sh
flutter upgrade
flutter config --no-analytics
flutter pub get
./ci.dart
