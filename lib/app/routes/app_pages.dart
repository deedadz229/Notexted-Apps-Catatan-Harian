import 'package:get/get.dart';

import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/note_binding.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/note/views/create_note_view.dart';
import '../modules/note/views/detail_note_view.dart';
import '../modules/note/views/edit_note_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.createNote,
      page: () => const CreateNoteView(),
      binding: NoteBinding(),
    ),
    GetPage(
      name: AppRoutes.detailNote,
      page: () => const DetailNoteView(),
      binding: NoteBinding(),
    ),
    GetPage(
      name: AppRoutes.editNote,
      page: () => const EditNoteView(),
      binding: NoteBinding(),
    ),
  ];
}
