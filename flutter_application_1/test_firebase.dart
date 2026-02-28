import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/services/firebase_service.dart';

void main() async {
  print('🔥 Testing Firebase Configuration...');

  try {
    // Test Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    // Test Firebase service
    var currentUser = FirebaseService.currentUser;
    print('👤 Current user: ${currentUser?.email ?? 'None'}');

    // Test database info
    var dbInfo = await FirebaseService.getDatabaseInfo();
    print('📊 Database info: ${dbInfo['message']}');

    print('🎉 Firebase configuration test completed successfully!');
  } catch (e) {
    print('❌ Firebase test failed: $e');
  }
}
