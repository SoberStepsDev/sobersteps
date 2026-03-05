class Profile {
  final String id;
  final String? username;
  final DateTime? sobrietyStartDate;
  final String? substanceType;
  final int checkinReminderHour;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String abVariant;
  final DateTime createdAt;

  Profile({
    required this.id,
    this.username,
    this.sobrietyStartDate,
    this.substanceType,
    this.checkinReminderHour = 21,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.abVariant = 'A',
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        username: json['username'],
        sobrietyStartDate: json['sobriety_start_date'] != null
            ? DateTime.parse(json['sobriety_start_date'])
            : null,
        substanceType: json['substance_type'],
        checkinReminderHour: json['checkin_reminder_hour'] ?? 21,
        emergencyContactName: json['emergency_contact_name'],
        emergencyContactPhone: json['emergency_contact_phone'],
        abVariant: json['ab_variant'] ?? 'A',
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'sobriety_start_date': sobrietyStartDate?.toIso8601String().split('T')[0],
        'substance_type': substanceType,
        'checkin_reminder_hour': checkinReminderHour,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'ab_variant': abVariant,
      };
}
