class ApiEndpoints {
  // Replace with your actual Laravel API Base URL
  // If testing on Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';

  // Patient
  static const String patients = '/patients';

  // Doctor
  static const String doctors = '/doctors';

  // Appointment
  static const String appointments = '/appointments';

  // Medical Record
  static const String medicalRecords = '/medical-records';

  // Payment
  static const String payments = '/payments';

  // Queue
  static const String queues = '/queues';
}
