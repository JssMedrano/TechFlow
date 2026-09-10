import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/image_service.dart';

/// Exibe evidência da OS — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class OrderImagePreview extends StatelessWidget {
  final String? path;
  final double height;

  const OrderImagePreview({super.key, this.path, this.height = 180});

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 40, color: AppTheme.textMuted),
            SizedBox(height: 8),
            Text('Sin imagen', style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: ImageService().loadBytes(path),
      builder: (context, snap) {
        if (!snap.hasData || snap.data == null) {
          return Container(
            height: height,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: AppTheme.accent),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            snap.data!,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
