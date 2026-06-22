import os, glob

mock_import = "import '../../core/network/mock_supabase.dart';\n"
files = glob.glob('c:/laragon/www/mbut/lib/presentation/providers/*.dart')

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    needs_update = False
    
    if 'final _supabase = Supabase.instance.client;' in content:
        content = content.replace("import 'package:supabase_flutter/supabase_flutter.dart';", "")
        content = content.replace("final _supabase = Supabase.instance.client;", "final dynamic _supabase = mockSupabase;")
        needs_update = True
    elif 'final dynamic _supabase = null;' in content:
        content = content.replace('final dynamic _supabase = null;', 'final dynamic _supabase = mockSupabase;')
        needs_update = True
        
    if needs_update:
        if mock_import not in content:
            content = mock_import + content
        with open(f, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Updated {f}")
