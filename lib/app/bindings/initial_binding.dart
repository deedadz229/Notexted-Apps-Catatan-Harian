import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/note_service.dart';
import '../services/theme_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(NoteService(), permanent: true);
    Get.put(ThemeService(), permanent: true);
  }
}
