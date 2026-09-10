import 'dart:io';

/// Detecção de plataforma desktop — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
bool get isDesktopPlatform =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;
