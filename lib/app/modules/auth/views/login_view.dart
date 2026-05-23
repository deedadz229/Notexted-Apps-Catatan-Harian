import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/apple_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/auth_shell.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Catatan Harian',
      subtitle: 'Masuk dan percayakan catatanmu pada kami:)',
      children: [
        AppTextField(
          controller: controller.loginEmailC,
          hint: 'Email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        Obx(
          () => AppTextField(
            controller: controller.loginPasswordC,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: controller.obscurePassword.value,
            suffix: IconButton(
              tooltip: controller.obscurePassword.value
                  ? 'Tampilkan password'
                  : 'Sembunyikan password',
              onPressed: controller.obscurePassword.toggle,
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
            child: const Text('Lupa password?'),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => AppleButton(
            label: 'Login',
            icon: Icons.arrow_forward_rounded,
            isLoading: controller.isLoading.value,
            onPressed: controller.login,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Belum punya akun?'),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.register),
              child: const Text('Register'),
            ),
          ],
        ),
      ],
    );
  }
}