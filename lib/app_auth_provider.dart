import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/scheduler.dart';
import 'package:share_lib/share_lib_auth.dart';

import 'config/auth_config.dart' show kGoogleServerClientId;
import 'models/user.dart';
import 'services/tabata_auth_api_service.dart';

class AppAuthProvider extends AuthProvider<User> {
  static AppAuthProvider? _instance;

  static AppAuthProvider get shared {
    _instance ??= AppAuthProvider._();
    return _instance!;
  }

  AppAuthProvider._()
      : super(
          firebaseAuth: FirebaseAuth.instance,
          authService: TabataAuthApiService.shared,
          googleServerClientId: kGoogleServerClientId,
        ) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      initialize();
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        fbUser.getIdToken().then((token) {
          if (token != null) {
            TabataAuthApiService.shared.setToken(token);
          }
        });
      }
    });
  }
}
