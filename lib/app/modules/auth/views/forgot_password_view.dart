import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/apple_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/auth_shell.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Reset Password',
      subtitle: 'Masukkan email, lalu Firebase akan mengirim link pemulihan.',
      children: [
        AppTextField(
          controller: controller.forgotEmailC,
          hint: 'Email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        Obx(
          () => AppleButton(
            label: 'Kirim Link',
            icon: Icons.send_rounded,
            isLoading: controller.isLoading.value,
            onPressed: controller.forgotPassword,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: Get.back,
          child: const Text('Kembali ke login'),
        ),
      ],
    );
  }
}
