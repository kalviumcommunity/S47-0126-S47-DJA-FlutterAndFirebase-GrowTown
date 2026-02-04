import 'package:flutter/material.dart';

// Blue-centric design tokens
const Color kPrimaryBlue = Color(0xFF2563EB);
const Color kPrimaryBlueLight = Color(0xFF60A5FA);
const Color kPrimaryBlueDark = Color(0xFF1E3A8A);

const Color kMutedBlue = Color(0xFFe6f0ff);

final LinearGradient kPrimaryGradient = LinearGradient(
  colors: [kPrimaryBlueLight, kPrimaryBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient kHeaderGradient = LinearGradient(
  colors: [Color(0xFF60A5FA), Color(0xFF1E3A8A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient kAccentGradient = LinearGradient(
  colors: [kPrimaryBlue, kPrimaryBlueDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
