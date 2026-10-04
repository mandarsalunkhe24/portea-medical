import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/professionals_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final String professionalId;
  final String professionalName;
  final String? bookingId;

  const WriteReviewScreen({
    super.key,
    required this.professionalId,
    required this.professionalName,
    this.bookingId,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 5.0;
  final TextEditingController _commentCtrl = TextEditingController();
  final List<String> _selectedTags = [];
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'Punctual',
    'Professional',
    'Caring',
    'Gentle & Painless',
    'Strict Hygiene & Sterile',
    'Patient & Respectful',
    'Clear Explanations',
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentCtrl.text.trim().isEmpty) {
      AppUtils.showToast(context, 'Please share a brief comment about the service', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profProv = Provider.of<ProfessionalsProvider>(context, listen: false);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);

    final review = Review(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      professionalId: widget.professionalId,
      userName: auth.currentUser?.name ?? 'Verified Patient',
      rating: _rating,
      date: DateTime.now(),
      tags: _selectedTags,
      comment: _commentCtrl.text.trim(),
      serviceRendered: 'Verified Home Healthcare Visit',
    );

    await profProv.addReview(review);

    if (widget.bookingId != null) {
      await bookingProv.markBookingReviewed(widget.bookingId!);
    }

    setState(() => _isSubmitting = false);

    if (mounted) {
      AppUtils.showToast(
        context,
        'Review published! Rating live updated.',
        isSuccess: true,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rate & Review Professional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Badge
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 42,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'How was your care experience with ${widget.professionalName}?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your honest feedback helps maintain the Portea Gold Quality Standard.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Rating Bar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              '$_rating out of 5 Stars',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 28),

            // Tag chips
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'What stood out about their care?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryTealLight,
                  checkmarkColor: AppTheme.primaryTeal,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryTealDark : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Detailed Feedback
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Write your review',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share details of their bedside manners, punctuality, and treatment efficacy...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Verified Review',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
