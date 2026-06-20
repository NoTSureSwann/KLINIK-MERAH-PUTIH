class User {
  final String id;
  final String name;
  final String email;
  final String role; // Patient, Doctor, Admin Loket

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}
