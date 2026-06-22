class MockSupabase {
  MockQuery from(String table) => MockQuery(table);
}

class MockQuery {
  final String table;
  MockQuery(this.table);

  Future<List<dynamic>> select([String? columns]) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  MockQuery eq(String col, dynamic val) => this;
  MockQuery order(String col, {bool ascending = false}) => this;

  Future<void> insert(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw Exception('API endpoint belum diimplementasikan untuk menambah data pada $table.');
  }

  Future<void> update(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw Exception('API endpoint belum diimplementasikan untuk mengupdate data pada $table.');
  }

  Future<void> delete() async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw Exception('API endpoint belum diimplementasikan untuk menghapus data pada $table.');
  }

  Future<dynamic> maybeSingle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return null;
  }
}

final mockSupabase = MockSupabase();
