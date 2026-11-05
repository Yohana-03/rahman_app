import 'package:finalrahman/core/json_utils.dart';

class ParentDetails {
  const ParentDetails({
    this.phone,
    this.address,
    this.emergencyContactNumber,
    this.emergencyContactRelationship,
  });

  final String? phone;
  final String? address;
  final String? emergencyContactNumber;
  final String? emergencyContactRelationship;

  factory ParentDetails.fromJson(Map<String, dynamic> json) {
    return ParentDetails(
      phone: readOptionalString(json['phone']),
      address: readOptionalString(json['address']),
      emergencyContactNumber: readOptionalString(
        json['emergency_contact_number'],
      ),
      emergencyContactRelationship: readOptionalString(
        json['emergency_contact_relationship'],
      ),
    );
  }
}

class ParentProfile {
  const ParentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.details,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final ParentDetails? details;

  String get phoneNumber => details?.phone ?? phone ?? '';

  factory ParentProfile.fromApiBody(Map<String, dynamic> body) {
    final json = readEnvelope(body);
    return ParentProfile(
      id: readInt(json['id']) ?? 0,
      name: readString(json['name'], fallback: 'Parent'),
      email: readString(json['email']),
      role: readString(json['role'], fallback: 'parent'),
      phone: readOptionalString(json['phone']),
      details: readMap(json['parent_profile']) == null
          ? null
          : ParentDetails.fromJson(readMap(json['parent_profile'])!),
    );
  }
}
