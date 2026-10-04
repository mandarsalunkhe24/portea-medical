import '../models/professional_model.dart';
import '../models/equipment_model.dart';
import '../models/review_model.dart';
import '../models/booking_model.dart';
import '../models/care_plan_model.dart';
import '../models/emergency_contact_model.dart';
import '../models/insurance_claim_model.dart';
import '../models/user_model.dart';
import '../core/pricing.dart';

class MockData {
  static final UserProfile defaultUser = UserProfile(
    id: 'user_001',
    name: 'Mandar Salunkhe',
    email: 'mandar.salunkhe@itm.edu',
    phone: '+91 98765 43210',
    defaultAddress: 'Flat 402, Green Meadows, Sector 4, Kharghar, Navi Mumbai',
    patients: [
      Patient(
        id: 'pat_001',
        name: 'Ramesh Salunkhe',
        age: 54,
        gender: 'Male',
        relationship: 'Father',
        healthNotes: 'Post-knee replacement rehab, Hypertension, Mild diabetes',
        address: 'Flat 402, Green Meadows, Sector 4, Kharghar, Navi Mumbai',
      ),
      Patient(
        id: 'pat_002',
        name: 'Sunita Salunkhe',
        age: 63,
        gender: 'Female',
        relationship: 'Mother',
        healthNotes: 'Cervical spondylosis, needs regular mobility exercises',
        address: 'Flat 402, Green Meadows, Sector 15, Kharghar, Navi Mumbai',
      ),
      Patient(
        id: 'pat_003',
        name: 'Mandar Salunkhe',
        age: 22,
        gender: 'Male',
        relationship: 'Self',
        healthNotes: 'Seasonal allergy, general wellness',
        address: 'Flat 402, Green Meadows, Sector 4, Kharghar, Navi Mumbai',
      ),
    ],
    savedAddresses: [
      'Flat 402, Green Meadows, Sector 4, Kharghar, Navi Mumbai',
      'Row House 12, Palm Beach Residency, Seawoods, Navi Mumbai',
      'Office: ITM Skills University Campus, Kharghar, Navi Mumbai',
    ],
  );

  static final List<Professional> professionals = [
    // 3 Nurses
    Professional(
      id: 'prof_nurse_1',
      name: 'Sister Ananya Sharma',
      role: 'Nurse',
      title: 'Senior Critical Care & Infusion Nurse',
      photoUrl:
          'https://images.unsplash.com/photo-1594824813583-16a827598857?auto=format&fit=crop&q=80&w=400',
      qualifications: 'B.Sc Nursing, Critical Care Fellowship',
      experienceYears: 7,
      languages: ['English', 'Hindi', 'Marathi'],
      specializations: [
        'Post-Op Wound Care',
        'IV Infusions & Injections',
        'Catheterization',
        'Tracheostomy Care'
      ],
      rating: 4.9,
      reviewCount: 148,
      pricePerVisit: PricingCalculator.nurseVisitBasePrice,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-4819',
      certifications: [
        Certification(
          name: 'Registered Nurse & Midwife (RN/RM)',
          issuingBody: 'Maharashtra Nursing Council',
          year: 2017,
          credentialId: 'MNC-2017-98421',
        ),
        Certification(
          name: 'Advanced Cardiac Life Support (ACLS)',
          issuingBody: 'American Heart Association',
          year: 2022,
          credentialId: 'AHA-ACLS-6623',
        ),
        Certification(
          name: 'Infection Prevention & Control',
          issuingBody: 'Portea Clinical Academy',
          year: 2023,
          credentialId: 'PCA-IPC-902',
        ),
      ],
      about:
          'Sister Ananya has over 7 years of specialized ICU and home healthcare experience. Skilled in aseptic wound dressing, cannula insertion, diabetic foot care, and vital monitoring.',
      ratingDistribution: {5: 128, 4: 16, 3: 3, 2: 1, 1: 0},
    ),
    Professional(
      id: 'prof_nurse_2',
      name: 'Brother Rajesh Nair',
      role: 'Nurse',
      title: 'Post-Surgical Nursing Specialist',
      photoUrl:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=400',
      qualifications: 'GNM (General Nursing and Midwifery), BLS',
      experienceYears: 5,
      languages: ['English', 'Hindi', 'Malayalam', 'Tamil'],
      specializations: [
        'Suture Removal',
        'Injections & Drips',
        'Ryle\'s Tube Insertion',
        'Palliative Care'
      ],
      rating: 4.8,
      reviewCount: 96,
      pricePerVisit: PricingCalculator.nurseVisitBasePrice,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-7128',
      certifications: [
        Certification(
          name: 'State Registered General Nurse',
          issuingBody: 'Kerala Nurses and Midwives Council',
          year: 2019,
          credentialId: 'KNMC-2019-3381',
        ),
        Certification(
          name: 'Basic Life Support (BLS)',
          issuingBody: 'Indian Red Cross Society',
          year: 2023,
          credentialId: 'IRCS-BLS-8834',
        ),
      ],
      about:
          'Rajesh provides compassionate and meticulous nursing care at home. Expert in administering difficult intravenous lines, nebulization regimens, and patient hygiene.',
      ratingDistribution: {5: 80, 4: 12, 3: 3, 2: 1, 1: 0},
    ),
    Professional(
      id: 'prof_nurse_3',
      name: 'Sister Priyanka Patel',
      role: 'Nurse',
      title: 'Geriatric Nursing & Diabetes Care Specialist',
      photoUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=400',
      qualifications: 'B.Sc Nursing, Diabetic Educator Diploma',
      experienceYears: 8,
      languages: ['English', 'Hindi', 'Gujarati', 'Marathi'],
      specializations: [
        'Insulin Titration',
        'Bedridden Patient Care',
        'Stoma & Ostomy Care',
        'Bedsore Management'
      ],
      rating: 4.95,
      reviewCount: 210,
      pricePerVisit: PricingCalculator.nurseVisitBasePrice,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-9340',
      certifications: [
        Certification(
          name: 'Certified Diabetic Educator (CDE)',
          issuingBody: 'National Diabetes Educator Program',
          year: 2018,
          credentialId: 'NDEP-2018-0442',
        ),
        Certification(
          name: 'Wound Ostomy Continence Care',
          issuingBody: 'Apollo MedSkills',
          year: 2021,
          credentialId: 'AMS-WOCC-512',
        ),
      ],
      about:
          'Known for her cheerful demeanor and gentle hand. Sister Priyanka excels at long-term care management, pressure ulcer reversal, and family counseling.',
      ratingDistribution: {5: 195, 4: 12, 3: 2, 2: 1, 1: 0},
    ),

    // 3 Physiotherapists
    Professional(
      id: 'prof_physio_1',
      name: 'Dr. Rohan Deshmukh (PT)',
      role: 'Physiotherapist',
      title: 'Orthopedic & Sports Rehabilitation Specialist',
      photoUrl:
          'https://images.unsplash.com/photo-1622902046580-2b47f47f5471?auto=format&fit=crop&q=80&w=400',
      qualifications: 'MPT (Orthopedics), BPT (Gold Medalist)',
      experienceYears: 9,
      languages: ['English', 'Hindi', 'Marathi'],
      specializations: [
        'Knee/Hip Replacement Rehab',
        'Spine & Back Pain Relief',
        'Frozen Shoulder Therapy',
        'Postural Correction'
      ],
      rating: 4.92,
      reviewCount: 184,
      pricePerVisit: PricingCalculator.physioVisitBasePrice,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-1938',
      certifications: [
        Certification(
          name: 'Master of Physiotherapy (Orthopedics)',
          issuingBody: 'Maharashtra University of Health Sciences',
          year: 2015,
          credentialId: 'MUHS-MPT-7721',
        ),
        Certification(
          name: 'Certified Mulligan Practitioner (CMP)',
          issuingBody: 'Mulligan Concept Teachers Association',
          year: 2018,
          credentialId: 'MCTA-CMP-904',
        ),
      ],
      about:
          'Dr. Rohan has helped over 1,500 patients regain independent mobility after joint replacements and spine surgeries. Utilizes manual therapy, IASTM, and targeted kinetic exercise.',
      ratingDistribution: {5: 168, 4: 12, 3: 3, 2: 1, 1: 0},
    ),
    Professional(
      id: 'prof_physio_2',
      name: 'Dr. Sneha Kulkarni (PT)',
      role: 'Physiotherapist',
      title: 'Neuro-Physiotherapist & Stroke Rehab Lead',
      photoUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=400',
      qualifications: 'MPT (Neurosciences), BPT',
      experienceYears: 6,
      languages: ['English', 'Hindi', 'Marathi', 'Gujarati'],
      specializations: [
        'Stroke / Hemiplegia Rehab',
        'Parkinson\'s Mobility Care',
        'Gait Training',
        'Balance & Fall Prevention'
      ],
      rating: 4.88,
      reviewCount: 112,
      pricePerVisit: PricingCalculator.physioVisitBasePrice,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-6621',
      certifications: [
        Certification(
          name: 'Certified Bobath & NDT Practitioner',
          issuingBody: 'International Bobath Instructors Training Assoc',
          year: 2020,
          credentialId: 'IBITA-NDT-312',
        ),
        Certification(
          name: 'Fellowship in Neurological Rehabilitation',
          issuingBody: 'Apollo Hospitals Educational Trust',
          year: 2021,
          credentialId: 'AHET-FNR-884',
        ),
      ],
      about:
          'Dr. Sneha is dedicated to neurological re-education and neuroplasticity stimulation. Highly skilled in helping post-stroke patients regain motor function and walking confidence.',
      ratingDistribution: {5: 98, 4: 10, 3: 3, 2: 1, 1: 0},
    ),
    Professional(
      id: 'prof_physio_3',
      name: 'Dr. Karthik Sundaram (PT)',
      role: 'Physiotherapist',
      title: 'Cardio-Pulmonary & Geriatric Physiotherapist',
      photoUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=400',
      qualifications: 'BPT, Fellowship in Pulmonary Rehabilitation',
      experienceYears: 10,
      languages: ['English', 'Hindi', 'Tamil', 'Telugu'],
      specializations: [
        'Chest Physiotherapy & Spirometry',
        'Post-COVID Lung Rehab',
        'Osteoarthritis Care',
        'Ergonomics & Posture'
      ],
      rating: 4.85,
      reviewCount: 140,
      pricePerVisit: PricingCalculator.physioVisitBasePrice,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-8054',
      certifications: [
        Certification(
          name: 'Indian Association of Physiotherapists (IAP)',
          issuingBody: 'Life Member - L-45129',
          year: 2014,
          credentialId: 'IAP-2014-45129',
        ),
        Certification(
          name: 'Advanced Pulmonary Conditioning',
          issuingBody: 'European Respiratory Society',
          year: 2021,
          credentialId: 'ERS-APC-1092',
        ),
      ],
      about:
          'With 10 years of hospital and domiciliary experience, Dr. Karthik brings gentle yet effective pulmonary drainage and functional mobility programs right to your living room.',
      ratingDistribution: {5: 120, 4: 15, 3: 4, 2: 1, 1: 0},
    ),

    // 2 Elderly Caregivers
    Professional(
      id: 'prof_elderly_1',
      name: 'Sunita Gaikwad',
      role: 'Elderly Caregiver',
      title: 'Senior Geriatric Attendant & Companionship Specialist',
      photoUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=400',
      qualifications: 'Geriatric Care Certificate (TISS), First Aid Certified',
      experienceYears: 6,
      languages: ['English', 'Hindi', 'Marathi'],
      specializations: [
        'Daily Vitals & Medication Charting',
        'Assisted Hygiene & Sponge Bath',
        'Nutritional Diet Assistance',
        'Dementia & Memory Support'
      ],
      rating: 4.94,
      reviewCount: 165,
      pricePerVisit: 499.0,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-5512',
      certifications: [
        Certification(
          name: 'Certificate in Elderly Care & Gerontology',
          issuingBody: 'Tata Institute of Social Sciences (TISS)',
          year: 2018,
          credentialId: 'TISS-GERI-2018-49',
        ),
        Certification(
          name: 'St. John Ambulance First Aid & CPR',
          issuingBody: 'St. John Ambulance India',
          year: 2022,
          credentialId: 'SJA-FA-7721',
        ),
      ],
      about:
          'Warm, dependable and patient. Sunita treats every senior citizen with the utmost respect and dignity. Special expertise in medication compliance and mild Alzheimer care.',
      ratingDistribution: {5: 152, 4: 11, 3: 2, 2: 0, 1: 0},
    ),
    Professional(
      id: 'prof_elderly_2',
      name: 'Mahesh Jadhav',
      role: 'Elderly Caregiver',
      title: 'Specialized Male Geriatric Attendant & Mobility Aide',
      photoUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
      qualifications: 'General Duty Assistant (GDA), Red Cross Certified',
      experienceYears: 7,
      languages: ['English', 'Hindi', 'Marathi'],
      specializations: [
        'Wheelchair & Bed Transfers',
        'Bedridden Patient Hygiene',
        'Walking Support & Fall Safety',
        'Doctor Visit Chaperone'
      ],
      rating: 4.89,
      reviewCount: 88,
      pricePerVisit: 499.0,
      isVerified: true,
      maskedAadhaar: 'XXXX-XXXX-9943',
      certifications: [
        Certification(
          name: 'General Duty Assistant (Healthcare Sector Skill)',
          issuingBody: 'National Skill Development Corporation (NSDC)',
          year: 2017,
          credentialId: 'NSDC-GDA-22194',
        ),
        Certification(
          name: 'Patient Safety & Fall Prevention',
          issuingBody: 'Portea Geriatric Wing',
          year: 2023,
          credentialId: 'PGW-PS-441',
        ),
      ],
      about:
          'Mahesh is strong, patient, and highly adept at safe transfers for heavy or immobile elderly patients. Trusted by over 50 families across Mumbai and Navi Mumbai.',
      ratingDistribution: {5: 78, 4: 8, 3: 2, 2: 0, 1: 0},
    ),
  ];

  static final List<Equipment> equipmentList = [
    Equipment(
      id: 'eq_001',
      name: 'Foldable Lightweight Wheelchair',
      category: 'Mobility',
      imageUrl:
          'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&q=80&w=500',
      description:
          'Heavy-duty chrome-plated steel frame with padded armrests, swing-away footrests, and puncture-proof solid rear wheels.',
      monthlyRate: 699.0,
      deposit: 1500.0,
      isAvailable: true,
      features: [
        'Weight capacity up to 120 kg',
        'Easy trunk fold for travel',
        'Dual brake system with parking locks',
        'High-density water-resistant cushion'
      ],
    ),
    Equipment(
      id: 'eq_002',
      name: 'Medical Oxygen Concentrator (5L/10L)',
      category: 'Respiratory',
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&q=80&w=500',
      description:
          'Continuous medical-grade 93% ± 3% oxygen delivery with built-in purity sensor, low noise operation, and digital display.',
      monthlyRate: 3499.0,
      deposit: 5000.0,
      isAvailable: true,
      features: [
        'Flow rate: 0.5 - 5 Litres/min continuous',
        'Low sound output (<43 dB) for quiet sleep',
        'Power failure and low purity safety alarms',
        'Comes with new cannula & humidifier bottle'
      ],
    ),
    Equipment(
      id: 'eq_003',
      name: 'Motorized ICU Hospital Bed (3-Function)',
      category: 'Patient Care',
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=500',
      description:
          'Electric remote-operated bed with backrest elevation, knee-rest elevation, and total height adjustment. Collapsible side rails.',
      monthlyRate: 3999.0,
      deposit: 6000.0,
      isAvailable: true,
      features: [
        'Handheld remote with one-touch presets',
        'Collapsible aluminum alloy safety side rails',
        'Central locking medical castors',
        'Includes 4-inch medical waterproof mattress'
      ],
    ),
    Equipment(
      id: 'eq_004',
      name: 'Adjustable Aluminium Reciprocal Walker',
      category: 'Mobility',
      imageUrl:
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&q=80&w=500',
      description:
          'Ultra-lightweight anodized aluminum reciprocal walking frame. Height adjustable with non-slip rubber tips for stability.',
      monthlyRate: 499.0,
      deposit: 1000.0,
      isAvailable: true,
      features: [
        'Reciprocal movement follows user step',
        'One-button folding mechanism',
        'Height adjustable 32" to 39"',
        'Ergonomic ribbed PVC hand grips'
      ],
    ),
    Equipment(
      id: 'eq_005',
      name: 'ResMed BiPAP / Auto-CPAP Machine',
      category: 'Respiratory',
      imageUrl:
          'https://images.unsplash.com/photo-1583912267670-6575ad4736f3?auto=format&fit=crop&q=80&w=500',
      description:
          'Dual-pressure respiratory support machine with integrated HumidAir heated humidifier and climate control technology.',
      monthlyRate: 4499.0,
      deposit: 8000.0,
      isAvailable: true,
      features: [
        'Bi-level pressure support (IPAP & EPAP)',
        'Built-in cellular modem for therapy tracking',
        'Heated tube to prevent condensation',
        'Includes sanitized headgear & nasal mask'
      ],
    ),
    Equipment(
      id: 'eq_006',
      name: 'Heavy Duty Compressor Nebulizer',
      category: 'Respiratory',
      imageUrl:
          'https://images.unsplash.com/photo-1631815589968-fdb09a223b1e?auto=format&fit=crop&q=80&w=500',
      description:
          'Powerful piston compressor for medication aerosol therapy. Ideal for bronchial asthma, COPD, and pediatric lung infections.',
      monthlyRate: 499.0,
      deposit: 1000.0,
      isAvailable: true,
      features: [
        'Fine aerosol particle size (MMAD ~3 µm)',
        'Low residual volume reduces medication waste',
        'Adult and pediatric mask included',
        'Thermal protector to avoid overheating'
      ],
    ),
    Equipment(
      id: 'eq_007',
      name: 'Alternating Pressure Anti-Bedsore Air Mattress',
      category: 'Patient Care',
      imageUrl:
          'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?auto=format&fit=crop&q=80&w=500',
      description:
          'Bubble pad air mattress with ultra-silent pressure pump. Constantly alternates inflation to prevent and heal decubitus ulcers.',
      monthlyRate: 799.0,
      deposit: 1500.0,
      isAvailable: true,
      features: [
        '130 individual bubble cells alternate cycles',
        'Adjustable pressure knob based on patient weight',
        'Medical grade non-toxic PVC fabric',
        'Low noise pump (<30 dB) with hang hooks'
      ],
    ),
    Equipment(
      id: 'eq_008',
      name: 'Height-Adjustable Deluxe Commode Chair',
      category: 'Patient Care',
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&q=80&w=500',
      description:
          'Rust-resistant steel commode with removable plastic bucket, splash guard, and comfortable cushioned seat top.',
      monthlyRate: 599.0,
      deposit: 1000.0,
      isAvailable: true,
      features: [
        'Can be placed bedside or over western toilet',
        'Removable 5L pail with cover & handle',
        'Skid-resistant rubber suction tips',
        'Folds flat for compact storage'
      ],
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'rev_001',
      professionalId: 'prof_nurse_1',
      userName: 'Vikram Joshi',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['Punctual', 'Professional', 'Gentle'],
      comment:
          'Sister Ananya arrived exactly on time in Portea uniform. Her technique for IV line insertion is painless and she maintained sterile conditions throughout.',
      serviceRendered: 'IV Infusion Visit',
    ),
    Review(
      id: 'rev_002',
      professionalId: 'prof_nurse_1',
      userName: 'Deepa Hegde',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 6)),
      tags: ['Caring', 'Knowledgeable', 'Punctual'],
      comment:
          'Took care of my mother\'s post-operative surgical wound. Checked vitals and explained how to keep it clean. Highly recommended!',
      serviceRendered: 'Wound Dressing Visit',
    ),
    Review(
      id: 'rev_003',
      professionalId: 'prof_nurse_1',
      userName: 'Suresh Patil',
      rating: 4.8,
      date: DateTime.now().subtract(const Duration(days: 14)),
      tags: ['Professional', 'Punctual'],
      comment:
          'Very systematic catheterization procedure. Very polite and reassuring.',
      serviceRendered: 'Catheter Care',
    ),
    Review(
      id: 'rev_004',
      professionalId: 'prof_nurse_2',
      userName: 'Manish Chawla',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['Punctual', 'Patient', 'Professional'],
      comment:
          'Rajesh was great with my father. He handled the suture removal with utmost precision and no discomfort.',
      serviceRendered: 'Suture Removal',
    ),
    Review(
      id: 'rev_005',
      professionalId: 'prof_nurse_3',
      userName: 'Kavita Menon',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 4)),
      tags: ['Caring', 'Knowledgeable', 'Punctual'],
      comment:
          'Sister Priyanka turned around my grandmother\'s stage-2 bedsore in 3 visits with specialized dressing. God bless her!',
      serviceRendered: 'Bedsore Management',
    ),
    Review(
      id: 'rev_006',
      professionalId: 'prof_physio_1',
      userName: 'Amitabh Sharma',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['Professional', 'Effective', 'Punctual'],
      comment:
          'Dr. Rohan has been helping me with post-TKR rehab. In just 8 sessions, my knee flexion improved from 70° to 115°. He brings all equipment like TENS and resistance bands.',
      serviceRendered: 'Knee Rehab Physiotherapy',
    ),
    Review(
      id: 'rev_007',
      professionalId: 'prof_physio_1',
      userName: 'Pooja Bhatia',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['Knowledgeable', 'Gentle', 'Professional'],
      comment:
          'Extremely knowledgeable doctor. Treated severe acute sciatica pain with targeted manual releases.',
      serviceRendered: 'Spine & Sciatica Therapy',
    ),
    Review(
      id: 'rev_008',
      professionalId: 'prof_physio_2',
      userName: 'Ganesh Naik',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['Patient', 'Caring', 'Professional'],
      comment:
          'Dr. Sneha is very patient with stroke recovery. She made my uncle walk across the hallway without support today. Such a proud moment for our family.',
      serviceRendered: 'Neuro Stroke Rehabilitation',
    ),
    Review(
      id: 'rev_009',
      professionalId: 'prof_physio_3',
      userName: 'Nalini Iyer',
      rating: 4.9,
      date: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['Punctual', 'Caring', 'Effective'],
      comment:
          'Dr. Karthik\'s chest physiotherapy cleared my dad\'s lung congestion remarkably. His breathing is noticeably easier.',
      serviceRendered: 'Chest Physiotherapy',
    ),
    Review(
      id: 'rev_010',
      professionalId: 'prof_elderly_1',
      userName: 'Siddharth Rao',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['Caring', 'Gentle', 'Punctual', 'Respectful'],
      comment:
          'Sunita ji is like family to us now. She attends to my 84-year-old mother with immense love, monitors her vitals twice a day, and keeps her happily engaged.',
      serviceRendered: 'Elderly Care Package',
    ),
    Review(
      id: 'rev_011',
      professionalId: 'prof_elderly_2',
      userName: 'Harish Mehta',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 8)),
      tags: ['Strong', 'Helpful', 'Punctual'],
      comment:
          'Mahesh is very dependable for bed-to-wheelchair transfers for my father who has Parkinson’s.',
      serviceRendered: 'Elderly Mobility Care',
    ),
    Review(
      id: 'rev_012',
      professionalId: 'prof_physio_1',
      userName: 'Meera Trivedi',
      rating: 4.8,
      date: DateTime.now().subtract(const Duration(days: 12)),
      tags: ['Professional', 'Punctual'],
      comment:
          'Clear explanations, good exercises chart provided on paper and follow-up.',
      serviceRendered: 'Shoulder Physiotherapy',
    ),
    Review(
      id: 'rev_013',
      professionalId: 'prof_nurse_3',
      userName: 'Arun Kothari',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 15)),
      tags: ['Gentle', 'Punctual'],
      comment:
          'Very clean and sanitary. Took blood glucose and adjusted insulin as directed by our physician.',
      serviceRendered: 'Diabetic Nursing',
    ),
    Review(
      id: 'rev_014',
      professionalId: 'prof_physio_2',
      userName: 'Rohit Shenoy',
      rating: 4.7,
      date: DateTime.now().subtract(const Duration(days: 18)),
      tags: ['Effective', 'Knowledgeable'],
      comment:
          'Good progress on balance training. Very structured 45 minute sessions.',
      serviceRendered: 'Balance Training',
    ),
    Review(
      id: 'rev_015',
      professionalId: 'prof_elderly_1',
      userName: 'Bhavna Parekh',
      rating: 5.0,
      date: DateTime.now().subtract(const Duration(days: 21)),
      tags: ['Caring', 'Punctual'],
      comment:
          'Sunita ensures timely morning tablets and makes nutritious vegetable soups. Outstanding care.',
      serviceRendered: 'Geriatric Daily Visit',
    ),
  ];

  static final List<EmergencyContact> defaultEmergencyContacts = [
    EmergencyContact(
      id: 'ec_amb',
      name: 'National Emergency Ambulance',
      relation: 'Emergency Service',
      phone: '108',
      isPrimary: false,
      isDefaultService: true,
    ),
    EmergencyContact(
      id: 'ec_portea',
      name: 'Portea 24x7 Clinical Helpline',
      relation: 'Healthcare Support',
      phone: '18001212323',
      isPrimary: false,
      isDefaultService: true,
    ),
    EmergencyContact(
      id: 'ec_prim',
      name: 'Mandar Salunkhe (Family)',
      relation: 'Son / Primary Guardian',
      phone: '9820289433',
      isPrimary: true,
      isDefaultService: false,
    ),
    EmergencyContact(
      id: 'ec_dr',
      name: 'Dr. V. K. Agarwal',
      relation: 'Family Physician',
      phone: '9820055443',
      isPrimary: false,
      isDefaultService: false,
    ),
  ];

  static final List<String> insurancePartners = [
    'Star Health and Allied Insurance',
    'HDFC ERGO General Insurance',
    'ICICI Lombard General Insurance',
    'Niva Bupa Health Insurance (Max Bupa)',
    'Care Health Insurance (Religare)',
    'Aditya Birla Health Insurance',
    'Bajaj Allianz General Insurance',
    'The New India Assurance Co. Ltd.',
    'National Insurance Company',
    'Tata AIG General Insurance',
  ];

  static final List<String> requiredClaimDocuments = [
    'Doctor\'s Prescription / Referral Letter advising home healthcare',
    'Portea Official Tax Invoice & Payment Receipt with GSTIN',
    'Professional\'s Clinical Daily Visit Sheets & Vitals Log',
    'Insurance Policy Copy / TPA Health ID Card',
    'Patient KYC (Aadhaar or PAN Card copy)',
    'Discharge Summary (if service follows hospital discharge)',
  ];

  static final List<String> sampleAvailableSlots = [
    '08:00 AM - 09:00 AM',
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '04:00 PM - 05:00 PM',
    '06:00 PM - 07:00 PM',
    '07:00 PM - 08:00 PM',
  ];

  /// Initial sample bookings so the app is alive on first launch
  static List<Booking> getInitialSampleBookings() {
    final now = DateTime.now();
    return [
      Booking(
        id: 'PRT-BK-1082',
        serviceTitle: 'Knee Rehab Physiotherapy',
        professionalId: 'prof_physio_1',
        professionalName: 'Dr. Rohan Deshmukh (PT)',
        professionalRole: 'Orthopedic Physiotherapist',
        professionalPhoto:
            'https://images.unsplash.com/photo-1622902046580-2b47f47f5471?auto=format&fit=crop&q=80&w=400',
        patientName: 'Ramesh Salunkhe',
        patientAge: 54,
        address: 'Flat 402, Green Meadows, Sector 4, Kharghar, Navi Mumbai',
        date: now.add(const Duration(days: 1)),
        timeSlot: '10:00 AM - 11:00 AM',
        price: PricingCalculator.physioVisitBasePrice,
        status: 'Professional Assigned',
        notes: 'Post-op knee flexion mobilization session 5.',
      ),
      Booking(
        id: 'PRT-BK-1075',
        serviceTitle: 'IV Infusion & Vital Monitoring',
        professionalId: 'prof_nurse_1',
        professionalName: 'Sister Ananya Sharma',
        professionalRole: 'Senior Critical Care Nurse',
        professionalPhoto:
            'https://images.unsplash.com/photo-1594824813583-16a827598857?auto=format&fit=crop&q=80&w=400',
        patientName: 'Ramesh Salunkhe',
        patientAge: 54,
        address: 'Flat 402, Green Meadows, Sector 4, Kharghar, Navi Mumbai',
        date: now.subtract(const Duration(days: 2)),
        timeSlot: '09:00 AM - 10:00 AM',
        price: PricingCalculator.nurseVisitBasePrice,
        status: 'Completed',
        notes: 'IV normal saline + multivitamin drip administered.',
        hasReview: true,
        evidence: ServiceCompletionEvidence(
          photoPath:
              'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&q=80&w=400',
          notes:
              'Vital signs stable: BP 124/82 mmHg, Pulse 74 bpm, Temp 98.4°F. Aseptic IV line completed without hematoma.',
          bloodPressure: '124/82',
          pulseRate: '74 bpm',
          temperature: '98.4 °F',
          professionalConfirmed: true,
          patientConfirmed: true,
          completedAt: now.subtract(const Duration(days: 2)),
        ),
      ),
    ];
  }

  /// Initial sample care plan
  static List<CarePlan> getInitialSampleCarePlans() {
    final now = DateTime.now();
    final pricing = PricingCalculator.calculateCarePlanPricing(
      serviceType: 'Physiotherapy',
      numberOfVisits: 10,
    );

    final visits = List.generate(10, (index) {
      final visitDate = now.subtract(Duration(days: 6 - (index * 2)));
      String status = 'Scheduled';
      DateTime? completedTime;
      if (index < 4) {
        status = 'Completed';
        completedTime = visitDate;
      }
      return CarePlanVisit(
        visitNumber: index + 1,
        date: visitDate,
        timeSlot: '10:00 AM - 11:00 AM',
        status: status,
        completedAt: completedTime,
      );
    });

    return [
      CarePlan(
        id: 'CP-2026-9021',
        title: 'Post-Op Knee Recovery Care Plan',
        serviceType: 'Physiotherapy',
        professionalId: 'prof_physio_1',
        professionalName: 'Dr. Rohan Deshmukh (PT)',
        professionalRole: 'Orthopedic Physiotherapist',
        patientName: 'Ramesh Salunkhe',
        startDate: now.subtract(const Duration(days: 6)),
        frequency: 'Alternate days',
        numberOfVisits: 10,
        preferredTimeSlot: '10:00 AM - 11:00 AM',
        originalPrice: pricing.originalTotal,
        discountAmount: pricing.discountAmount,
        finalPrice: pricing.finalTotal,
        status: 'Active',
        visits: visits,
      ),
    ];
  }

  /// Initial sample insurance claims
  static List<InsuranceClaim> getInitialSampleClaims() {
    return [
      InsuranceClaim(
        id: 'CLM-IN-7041',
        policyNumber: 'STAR-HEALTH-99410382',
        insurerName: 'Star Health and Allied Insurance',
        patientName: 'Ramesh Salunkhe',
        serviceBooked: '10-Visit Post-Surgical Physiotherapy',
        phone: '+919876543210',
        documentFileNames: [
          'Doctor_Referral_Letter.pdf',
          'Portea_GST_Invoice_CP9021.pdf',
          'Treatment_Log_Sheet.pdf'
        ],
        status: 'In Review',
        submissionDate: DateTime.now().subtract(const Duration(days: 3)),
        estimatedClaimAmount: 6791.50,
        trackingRemarks:
            'TPA query answered. Under assessment by Senior Medical Examiner.',
      ),
    ];
  }
}
