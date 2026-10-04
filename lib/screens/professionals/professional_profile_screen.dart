import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/pricing.dart';
import '../../core/utils.dart';
import '../../providers/professionals_provider.dart';
import '../../widgets/custom_network_image.dart';
import '../../widgets/document_preview_dialog.dart';
import '../booking/booking_calendar_screen.dart';
import '../care_plan/care_plan_creator_screen.dart';
import '../reviews/write_review_screen.dart';

class ProfessionalProfileScreen extends StatelessWidget {
  final String professionalId;

  const ProfessionalProfileScreen({super.key, required this.professionalId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profProv = Provider.of<ProfessionalsProvider>(context);
    final prof = profProv.getProfessionalById(professionalId);
    final reviews = profProv.getReviewsForProfessional(professionalId);

    if (prof == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Professional Details')),
        body: const Center(child: Text('Professional profile not found.')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(prof.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              AppUtils.showToast(
                context,
                'Portea verified profile link copied for ${prof.name}',
                isSuccess: true,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Photo & Bio Header
            Container(
              width: double.infinity,
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Hero(
                    tag: 'prof_photo_${prof.id}',
                    child: CustomNetworkImage(
                      imageUrl: prof.photoUrl,
                      fallbackText: prof.name,
                      width: 110,
                      height: 110,
                      isCircle: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prof.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: AppTheme.successGreen, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prof.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${prof.qualifications} • ${prof.experienceYears} Years Clinical Experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Rating & Reviews Summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingBarIndicator(
                        rating: prof.rating,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${prof.rating} (${prof.reviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Price Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTealLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${PricingCalculator.formatCurrency(prof.pricePerVisit)} / Home Visit',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryTealDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // About Section
            _buildSection(
              title: 'About the Professional',
              child: Text(
                prof.about,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            // Languages Spoken
            _buildSection(
              title: 'Languages Spoken',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prof.languages
                    .map((lang) => Chip(
                          label: Text(lang),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ))
                    .toList(),
              ),
            ),

            // Specialization Areas
            _buildSection(
              title: 'Specializations & Clinical Skills',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: prof.specializations
                    .map((spec) => Chip(
                          avatar: const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppTheme.primaryTeal,
                          ),
                          label: Text(spec),
                          backgroundColor: AppTheme.primaryTealLight,
                          side: BorderSide.none,
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryTealDark,
                          ),
                        ))
                    .toList(),
              ),
            ),

            // Verified Documents Section
            _buildSection(
              title: 'Verified Documents & Credentials',
              subtitle: 'Audited & validated by Portea Clinical Compliance Board',
              child: Column(
                children: [
                  // ID Proof
                  _buildDocumentTile(
                    context,
                    title: 'Government Identity Proof',
                    subtitle: 'Aadhaar Card (${prof.maskedAadhaar})',
                    identifier: prof.maskedAadhaar,
                    statusText: 'Verified',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 10),
                  // Background Check
                  _buildDocumentTile(
                    context,
                    title: 'Background & Police Verification',
                    subtitle: prof.backgroundCheckStatus,
                    identifier: 'POLICE-VERIF-MH-2026',
                    statusText: 'Clear',
                    icon: Icons.security_rounded,
                  ),
                  const SizedBox(height: 10),
                  // Portea Gold Seal
                  _buildDocumentTile(
                    context,
                    title: 'Portea Clinical Accreditation',
                    subtitle: prof.porteaSealStatus,
                    identifier: 'PORT-ACCRED-GLD-889',
                    statusText: 'Accredited',
                    icon: Icons.verified_user_rounded,
                  ),
                  const SizedBox(height: 12),
                  // Certifications List
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Medical & Nursing Council Certifications:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...prof.certifications.map((cert) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: AppTheme.successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cert.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${cert.issuingBody} (${cert.year})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 18,
                                color: AppTheme.primaryTeal,
                              ),
                              tooltip: 'Preview Credential',
                              onPressed: () {
                                DocumentPreviewDialog.show(
                                  context,
                                  title: cert.name,
                                  subtitle: cert.issuingBody,
                                  identifier: cert.credentialId,
                                  verifiedDate: 'Issued in ${cert.year}',
                                  verificationBody: cert.issuingBody,
                                );
                              },
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // Rating Breakdown (5 to 1 Star)
            _buildSection(
              title: 'Ratings & Reviews Breakdown',
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            '${prof.rating}',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          RatingBarIndicator(
                            rating: prof.rating,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 16.0,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${prof.reviewCount} total reviews',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final count = prof.ratingDistribution[star] ?? 0;
                            final fraction = prof.reviewCount > 0
                                ? (count / prof.reviewCount)
                                : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Text(
                                    '$star ★',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: fraction,
                                        backgroundColor: const Color(0xFFE2E8F0),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          star >= 4
                                              ? AppTheme.successGreen
                                              : (star == 3
                                                  ? Colors.amber
                                                  : AppTheme.emergencyRed),
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '$count',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Write review button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WriteReviewScreen(
                            professionalId: prof.id,
                            professionalName: prof.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('Write a Patient Review'),
                  ),
                ],
              ),
            ),

            // Patient Reviews List
            _buildSection(
              title: 'Patient Reviews (${reviews.length})',
              child: reviews.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No reviews yet. Be the first to leave one!'),
                      ),
                    )
                  : Column(
                      children: reviews.map((rev) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      rev.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      AppUtils.formatDate(rev.date),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: rev.rating,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 14.0,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      rev.serviceRendered,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  rev.comment,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                if (rev.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: rev.tags
                                        .map((tag) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: Colors.grey.shade300),
                                              ),
                                              child: Text(
                                                tag,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          )).toList(),
                    ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CarePlanCreatorScreen(
                        preselectedProfessional: prof,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('10-Visit Plan (15% Off)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingCalendarScreen(
                        professional: prof,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Book Single Visit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDocumentTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String identifier,
    required String statusText,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.successGreenLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.successGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.remove_red_eye_outlined,
              size: 18,
              color: AppTheme.primaryTeal,
            ),
            tooltip: 'View Document Seal',
            onPressed: () {
              DocumentPreviewDialog.show(
                context,
                title: title,
                subtitle: subtitle,
                identifier: identifier,
              );
            },
          ),
        ],
      ),
    );
  }
}
