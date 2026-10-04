class Certification {
  final String name;
  final String issuingBody;
  final int year;
  final String credentialId;

  Certification({
    required this.name,
    required this.issuingBody,
    required this.year,
    required this.credentialId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'issuingBody': issuingBody,
      'year': year,
      'credentialId': credentialId,
    };
  }

  factory Certification.fromMap(Map<String, dynamic> map) {
    return Certification(
      name: map['name'] ?? '',
      issuingBody: map['issuingBody'] ?? '',
      year: map['year'] ?? 2020,
      credentialId: map['credentialId'] ?? '',
    );
  }
}

class Professional {
  final String id;
  final String name;
  final String role; // 'Nurse', 'Physiotherapist', 'Elderly Caregiver'
  final String title; // e.g. 'Senior Critical Care Nurse'
  final String photoUrl;
  final String qualifications; // e.g. 'B.Sc Nursing, GNM'
  final int experienceYears;
  final List<String> languages;
  final List<String> specializations;
  final double rating;
  final int reviewCount;
  final double pricePerVisit;
  final bool isVerified;
  final String maskedAadhaar;
  final List<Certification> certifications;
  final String backgroundCheckStatus;
  final String porteaSealStatus;
  final String about;
  final Map<int, int> ratingDistribution; // 5: 85, 4: 12, 3: 2, 2: 1, 1: 0

  Professional({
    required this.id,
    required this.name,
    required this.role,
    required this.title,
    required this.photoUrl,
    required this.qualifications,
    required this.experienceYears,
    required this.languages,
    required this.specializations,
    required this.rating,
    required this.reviewCount,
    required this.pricePerVisit,
    this.isVerified = true,
    required this.maskedAadhaar,
    required this.certifications,
    this.backgroundCheckStatus = 'Verified & Clear',
    this.porteaSealStatus = 'Portea Gold Standard Verified',
    required this.about,
    required this.ratingDistribution,
  });

  Professional copyWith({
    double? rating,
    int? reviewCount,
    Map<int, int>? ratingDistribution,
  }) {
    return Professional(
      id: id,
      name: name,
      role: role,
      title: title,
      photoUrl: photoUrl,
      qualifications: qualifications,
      experienceYears: experienceYears,
      languages: languages,
      specializations: specializations,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      pricePerVisit: pricePerVisit,
      isVerified: isVerified,
      maskedAadhaar: maskedAadhaar,
      certifications: certifications,
      backgroundCheckStatus: backgroundCheckStatus,
      porteaSealStatus: porteaSealStatus,
      about: about,
      ratingDistribution: ratingDistribution ?? this.ratingDistribution,
    );
  }
}
