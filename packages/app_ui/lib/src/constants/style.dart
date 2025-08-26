import 'package:app_ui/src/constants/radius.dart';
import 'package:flutter/material.dart';

/// Outlined border with default border radius. It is used to avoid
/// boilerplate code.
OutlineInputBorder outlinedBorder({
  double borderRadius = defaultBorderRadius,
  BorderSide? borderSide,
}) =>
    OutlineInputBorder(
      borderSide: borderSide ?? BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
    );
    