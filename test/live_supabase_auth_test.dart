import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubantu/core/config/app_config.dart';

class _RealHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  test('Live Supabase Auth & Queries Test with real credentials', () async {
    final client = SupabaseClient(
      AppConfig.supabaseUrl,
      AppConfig.supabaseAnonKey,
    );

    const testEmail = String.fromEnvironment('TEST_EMAIL');
    const testPassword = String.fromEnvironment('TEST_PASSWORD');
    if (testEmail.isEmpty || testPassword.isEmpty) {
      stdout.writeln('TEST_EMAIL or TEST_PASSWORD not provided. Skipping live auth.');
      return;
    }

    final authRes = await client.auth.signInWithPassword(
      email: testEmail,
      password: testPassword,
    );

    expect(authRes.session, isNotNull);
    expect(authRes.user, isNotNull);

    final user = authRes.user!;
    final session = authRes.session!;

    stdout.writeln('=== SUPABASE AUTH LIVE TEST ===');
    stdout.writeln('AUTH_SUCCESS: true');
    stdout.writeln('USER_ID: ${user.id}');
    stdout.writeln('USER_EMAIL: ${user.email}');
    stdout.writeln('USER_METADATA: ${user.userMetadata}');
    stdout.writeln('SESSION_ACCESS_TOKEN_PREFIX: ${session.accessToken.substring(0, 20)}...');

    final tablesToTest = [
      'profiles',
      'service_orders',
      'tasks',
      'notifications',
      'barter_items',
      'loyalty_points',
      'ratings',
      'schedules',
      'sos_reports',
      'chat_rooms',
      'chat_messages',
    ];

    stdout.writeln('=== QUERY TEST FOR TABLES ===');
    for (final table in tablesToTest) {
      try {
        final res = await client.from(table).select().limit(2);
        stdout.writeln('TABLE_$table: SUCCESS (count: ${(res as List).length}, data: $res)');
      } catch (e) {
        stdout.writeln('TABLE_$table: ERROR ($e)');
      }
    }
  });
}
