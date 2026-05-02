class UserModel {
  final String uid;
  final String fullName;
  final String? rollNumber;
  final String? department;
  final String? semester;
  final String? roomNumber;
  final String? hostelBlock;
  final String? employeeId;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.fullName,
    this.rollNumber,
    this.department,
    this.semester,
    this.roomNumber,
    this.hostelBlock,
    this.employeeId,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['full_name'] ?? '',
      rollNumber: map['roll_number'],
      department: map['department'],
      semester: map['semester'],
      roomNumber: map['room_number'],
      hostelBlock: map['hostel_block'],
      employeeId: map['employee_id'],
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      if (rollNumber != null) 'roll_number': rollNumber,
      if (department != null) 'department': department,
      if (semester != null) 'semester': semester,
      if (roomNumber != null) 'room_number': roomNumber,
      if (hostelBlock != null) 'hostel_block': hostelBlock,
      if (employeeId != null) 'employee_id': employeeId,
      'email': email,
      'role': role,
    };
  }
}
