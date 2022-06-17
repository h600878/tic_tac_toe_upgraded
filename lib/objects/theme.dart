import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MyTheme {
  /// What [ThemeMode] the app is using, initial theme is [ThemeMode.system]
  static ThemeMode _globalTheme = ThemeMode.system;

  static ThemeMode get globalTheme => _globalTheme;

  static void setGlobalTheme(ThemeMode mode) {
    _globalTheme = mode;
    _saveTheme(mode);
  }

  static Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "global-theme", mode.toString()); // TODO save as JSON format
  }

  static Future<String> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("global-theme") ?? ThemeMode.system.toString();
  }

  static Future<void> saveMaterial(ColorWrapper material) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(material.id, json.encode(material.toJSON()));
  }

  // TODO see which ones are usable
  static ColorWrapper appBarColorsLight = ColorWrapper(Colors.blue),
      appBarColorsDark = ColorWrapper(const Color(0xff121212)),
      primaryColorsLight = ColorWrapper(Colors.blue, id: "primary-color-light"),
      primaryColorsDark = ColorWrapper(Colors.blue, id: "primary-color-dark"),
      backgroundLight = ColorWrapper(Colors.white),
      backgroundDark = ColorWrapper(const Color(0xff121212)),
      player1Color = ColorWrapper(Colors.blue, id: "player1-color"),
      player2Color = ColorWrapper(Colors.red, id: "player2-color");

  /// Returns 'true' if the [globalTheme] is set to [ThemeMode.dark], either forced or with system set to dark
  static bool isDark(BuildContext context) =>
      globalTheme == ThemeMode.dark ||
      globalTheme != ThemeMode.light &&
          MediaQuery.of(context).platformBrightness == Brightness.dark;
}

/// A helper class used to wrap a [Color] object, so 'pass by pointer' can be used
class ColorWrapper {
  ColorWrapper(this.color, {String id = ""}) : _id = id;

  ColorWrapper.fromJSON(Map<String, dynamic> json)
      : color = Color(json["color"] ?? Colors.blue.value),
        _id = json["id"] ?? "";

  /// The [color] to be wrapped
  Color color;

  final String _id;

  /// A unique [id] that can be used to get this specific object from [SharedPreferences] for example
  String get id => _id;

  Map<String, dynamic> toJSON() => {'id': _id, 'color': color.value};

  @override
  String toString() => "id=$id, object=$color";

  @override
  bool operator ==(Object other) {
    if (this == other) {
      return true;
    }
    if (other is! ColorWrapper) {
      return false;
    }
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
