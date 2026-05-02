import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSession {
  final String id;
  final String adminId;
  final String adminName;
  final String subject;
  final String department;
  final String semester;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;

  AttendanceSession({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.subject,
    required this.department,
    required this.semester,
    required this.createdAt,
    required this.expiresAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'adminName': adminName,
      'subject': subject,
      'department': department,
      'semester': semester,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': isActive,
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      id: map['id'] ?? '',
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? '',
      subject: map['subject'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
    );
  }
}
