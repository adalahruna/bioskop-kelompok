Dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MoviePosterCard extends StatelessWidget {
  final String posterUrl;
  final VoidCallback onTap;

  const MoviePosterCard({
    super.key,
    required this.posterUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130, // Lebar poster
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(posterUrl),
            fit: BoxFit.cover,
            // Tampilkan error jika gambar gagal dimuat
            onError: (exception, stackTrace) => const Icon(
              Icons.error_outline,
              color: AppTheme.primaryGold,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkBackground.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
      ),
    );
  }
}
