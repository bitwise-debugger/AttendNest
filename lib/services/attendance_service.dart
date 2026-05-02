import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createSession(AttendanceSession session) async {
    try {
      await _firestore.collection('sessions').doc(session.id).set(session.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceSession?> getSession(String sessionId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('sessions').doc(sessionId).get();
      if (doc.exists) {
        return AttendanceSession.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> endSession(String sessionId) async {
    try {
      await _firestore.collection('sessions').doc(sessionId).update({'isActive': false});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAttendance(AttendanceRecord record) async {
    try {
      // Check if student already marked attendance for this session
      final existing = await _firestore
          .collection('attendance_records')
          .where('sessionId', isEqualTo: record.sessionId)
          .where('studentId', isEqualTo: record.studentId)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Attendance already marked for this session');
      }

      await _firestore.collection('attendance_records').doc(record.id).set(record.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
