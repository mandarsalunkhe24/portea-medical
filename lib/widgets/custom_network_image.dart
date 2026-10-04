import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../core/theme.dart';

IconData equipmentCategoryIcon(String category) {
  switch (category) {
    case 'Mobility':
      return Icons.accessible;
    case 'Respiratory':
      return Icons.air;
    case 'Patient Care':
      return Icons.bed_outlined;
    case 'Monitoring':
      return Icons.monitor_heart_outlined;
    default:
      return Icons.medical_services_outlined;
  }
}

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool isCircle;
  final IconData fallbackIcon;
  final String? fallbackText;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12.0,
    this.isCircle = false,
    this.fallbackIcon = Icons.medical_services_outlined,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl.isEmpty) {
      imageWidget = _buildFallback();
    } else {
      if (kIsWeb) {
        // On Chrome/web, Unsplash images can fail after navigating away and back
        // (browser CORS cache quirk). "fallback" retries through a plain <img>
        // element when the normal fetch is blocked, so the photo still shows.
        imageWidget = Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _buildLoading();
          },
          errorBuilder: (context, error, stack) => _buildFallback(),
        );
      } else {
        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => _buildLoading(),
          errorWidget: (context, url, error) => _buildFallback(),
        );
      }
    }

    if (isCircle) {
      return ClipOval(
        child: SizedBox(
          width: width ?? 50,
          height: height ?? 50,
          child: imageWidget,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageWidget,
    );
  }

  String _initials(String name) {
    final cleaned = name
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(
          RegExp(r'^(Dr\.?|Sister|Brother|Mr\.?|Mrs\.?|Ms\.?)\s+', caseSensitive: false),
          '',
        )
        .trim();
    final parts = cleaned.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.withOpacity(0.12),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    final text = fallbackText;
    return Container(
      width: width,
      height: height,
      color: AppTheme.primaryTealLight,
      child: Center(
        child: (text != null && text.trim().isNotEmpty)
            ? Text(
                _initials(text),
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: ((height ?? width ?? 50) * 0.36).clamp(12.0, 40.0),
                ),
              )
            : Icon(
                fallbackIcon,
                color: AppTheme.primaryTeal,
                size: (width != null && width! < 40)
                    ? 18
                    : ((height ?? 0) >= 120 ? 48 : 28),
              ),
      ),
    );
  }
}
