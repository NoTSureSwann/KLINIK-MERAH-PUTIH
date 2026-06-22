class ApiEndpoints {
  // Base URL for the API
  static const String baseUrl = 'http://localhost:8000/api';

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
