#!/bin/sh
flutter upgrade
flutter config --no-analytics
flutter clean
flutter pub get
./ci.dart
