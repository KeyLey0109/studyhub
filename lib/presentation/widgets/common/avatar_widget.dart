import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key, required this.name, this.imageUrl, this.radius = 24, this.onTap,
  });

  Color _colorFromName(String name) {
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.red, Colors.indigo, Colors.pink,
    ];
    if (name.isEmpty) return AppTheme.primaryBlue;
    return colors[name.codeUnitAt(0) % colors.length];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http')) {
        provider = NetworkImage(imageUrl!);
      } else {
        final file = File(imageUrl!);
        if (file.existsSync()) {
          provider = FileImage(file);
        }
      }
    }

    Widget avatar;
    if (provider != null) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: provider,
        backgroundColor: _colorFromName(name),
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: _colorFromName(name),
        child: Text(
          _initials(name),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.7,
          ),
        ),
      );
    }

    if (onTap != null) return GestureDetector(onTap: onTap, child: avatar);
    return avatar;
  }
}
