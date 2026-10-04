class Equipment {
  final String id;
  final String name;
  final String category; // 'Mobility', 'Respiratory', 'Patient Care', 'Monitoring'
  final String imageUrl;
  final String description;
  final double monthlyRate;
  final double deposit;
  final bool isAvailable;
  final List<String> features;
  final String sanitizedStatus;

  Equipment({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.monthlyRate,
    required this.deposit,
    this.isAvailable = true,
    required this.features,
    this.sanitizedStatus = 'Medical Grade Sanitized & Certified',
  });
}
