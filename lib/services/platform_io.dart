import 'dart:io';

/// Detecção de plataforma desktop
bool get isDesktopPlatform =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;
