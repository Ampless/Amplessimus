#!/bin/sh
flutter upgrade
flutter config --no-analytics && \
flutter clean && \
flutter pub get && \
dart run make.dart $@
