import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/apple_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/auth_shell.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Buat Akun',
      subtitle: 'Simpan catatanmu di Firebase agar tetap aman dan sinkron.',
      children: [
        AppTextField(
          controller: controller.registerEmailC,
          hint: 'Email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        Obx(
          () => AppTextField(
            controller: controller.registerPasswordC,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: controller.obscurePassword.value,
            suffix: IconButton(
              tooltip: 'Toggle password',
              onPressed: controller.obscurePassword.toggle,
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => AppTextField(
            controller: controller.registerConfirmPasswordC,
            hint: 'Konfirmasi password',
            icon: Icons.verified_user_outlined,
            obscureText: controller.obscurePassword.value,
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => AppleButton(
            label: 'Register',
            icon: Icons.person_add_alt_1_rounded,
            isLoading: controller.isLoading.value,
            onPressed: controller.register,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sudah punya akun?'),
            TextButton(
              onPressed: () => Get.offNamed(AppRoutes.login),
              child: const Text('Login'),
            ),
          ],
        ),
      ],
    );
  }
}
