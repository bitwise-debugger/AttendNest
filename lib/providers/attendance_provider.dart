import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final _uuid = const Uuid();

  bool _isLoading = false;
  String? _errorMessage;
  AttendanceSession? _currentSession;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AttendanceSession? get currentSession => _currentSession;

  Future<AttendanceSession?> createNewSession({
    required String adminId,
    required String adminName,
    required String subject,
    required String department,
    required String semester,
    required int durationMinutes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sessionId = _uuid.v4();
      final now = DateTime.now();
      
      final session = AttendanceSession(
        id: sessionId,
        adminId: adminId,
        adminName: adminName,
        subject: subject,
        department: department,
        semester: semester,
        createdAt: now,
        expiresAt: now.add(Duration(minutes: durationMinutes)),
      );

      await _attendanceService.createSession(session);
      _currentSession = session;
      _isLoading = false;
      notifyListeners();
      return session;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> endCurrentSession() async {
    if (_currentSession == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _attendanceService.endSession(_currentSession!.id);
      _currentSession = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> markAttendance({
    required String sessionId,
    required String studentId,
    required String studentName,
    required String rollNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First, verify if the session exists and is active
      final session = await _attendanceService.getSession(sessionId);
      if (session == null) {
        throw Exception('Invalid QR Code');
      }
      if (!session.isActive) {
        throw Exception('This session has already ended');
      }
      if (DateTime.now().isAfter(session.expiresAt)) {
        throw Exception('This session has expired');
      }

      final record = AttendanceRecord(
        id: _uuid.v4(),
        sessionId: sessionId,
        studentId: studentId,
        studentName: studentName,
        rollNumber: rollNumber,
        timestamp: DateTime.now(),
      );

      await _attendanceService.markAttendance(record);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
