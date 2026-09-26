import 'package:flutter/foundation.dart';

/// Service managing the global Travel Mode state (Group vs Solo) across the app.
class TravelModeService {
  /// Reactive ValueNotifier for solo mode state.
  /// false = Group Mode (Default), true = Solo Mode.
  static final ValueNotifier<bool> isSoloNotifier = ValueNotifier<bool>(false);

  /// Current mode getter
  static bool get isSolo => isSoloNotifier.value;

  /// Setter for solo mode
  static set isSolo(bool value) {
    isSoloNotifier.value = value;
  }

  /// Explicit setter helper
  static void setSolo(bool solo) {
    isSoloNotifier.value = solo;
  }

  /// Toggle between Group and Solo mode
  static void toggle() {
    isSoloNotifier.value = !isSoloNotifier.value;
  }
}
