import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeId {
  global(both: "global-theme"),
  primaryColor(light: "primary-color-light", dark: "primary-color-dark"),
  player1(both: "player1-color"),
  player2(both: "player2-color");

  const ThemeId({this.light, this.dark, this.both});

  final String? light;
  final String? dark;
  final String? both;
}

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
    prefs.setString(ThemeId.global.both!, mode.toString());
  }

  static Future<String> getSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ThemeId.global.both!) ?? ThemeMode.system.toString();
  }

  static Future<void> saveMaterial(ColorWrapper material) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(material.id, json.encode(material.toJSON()));
  }

  // TODO see which ones are usable
  static ColorWrapper appBarColorsLight = ColorWrapper(Colors.blue),
      appBarColorsDark = ColorWrapper(const Color(0xff121212)),
      primaryColorsLight =
          ColorWrapper(Colors.blue, id: ThemeId.primaryColor.light!),
      primaryColorsDark =
          ColorWrapper(Colors.blue, id: ThemeId.primaryColor.dark!),
      backgroundLight = ColorWrapper(Colors.white),
      backgroundDark = ColorWrapper(const Color(0xff121212)),
      player1Color = ColorWrapper(Colors.blue, id: ThemeId.player1.both!),
      player2Color = ColorWrapper(Colors.red, id: ThemeId.player2.both!);

  /// Returns 'true' if the [globalTheme] is set to [ThemeMode.dark], or [ThemeMode.system] and is dark
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

  /// Converts [id] and [color.value] to a Map, that can be converted to [JSON] format
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