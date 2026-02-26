import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kznhbcwozpjflewlzxnu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt6bmhiY3dvenBqZmxld2x6eG51Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwMTU4NTcsImV4cCI6MjA4NzU5MTg1N30.CRgPK-BExwci8l6EHmJ3V9jH-ElABom62hejiBqyN_4'
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test 3AM',
      home: const TestPage(),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test INSERT')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final client = Supabase.instance.client;
            final user = client.auth.currentUser;

            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Brak użytkownika – zaloguj się')),
              );
              return;
            }

            try {
              await client.from('three_am_wall').insert({
                'user_id': user.id,
                'content': 'Test z Fluttera – 26 luty – bez toksycznych słów',
                'is_visible': false,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dodano! Sprawdź bazę')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Błąd: $e')),
              );
            }
          },
          child: const Text('Dodaj wpis 3 AM'),
        ),
      ),
    );
  }
}