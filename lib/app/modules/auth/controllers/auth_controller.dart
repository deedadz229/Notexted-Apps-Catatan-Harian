import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class AuthController extends GetxController {
  final loginEmailC = TextEditingController();
  final loginPasswordC = TextEditingController();
  final registerEmailC = TextEditingController();
  final registerPasswordC = TextEditingController();
  final registerConfirmPasswordC = TextEditingController();
  final forgotEmailC = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  Future<void> login() async {
    if (!_isEmail(loginEmailC.text) || loginPasswordC.text.length < 6) {
      _showError('Email valid dan password minimal 6 karakter.');
      return;
    }

    await _runAuthAction(
      action: () => AuthService.to.login(
        email: loginEmailC.text,
        password: loginPasswordC.text,
      ),
      successMessage: 'Selamat datang kembali.',
      onSuccess: () => Get.offAllNamed(AppRoutes.home),
    );
  }

  Future<void> register() async {
    if (!_isEmail(registerEmailC.text)) {
      _showError('Masukkan email yang valid.');
      return;
    }
    if (registerPasswordC.text.length < 6) {
      _showError('Password minimal 6 karakter.');
      return;
    }
    if (registerPasswordC.text != registerConfirmPasswordC.text) {
      _showError('Konfirmasi password belum sama.');
      return;
    }

    await _runAuthAction(
      action: () => AuthService.to.register(
        email: registerEmailC.text,
        password: registerPasswordC.text,
      ),
      successMessage: 'Akun berhasil dibuat.',
      onSuccess: () => Get.offAllNamed(AppRoutes.home),
    );
  }

  Future<void> forgotPassword() async {
    if (!_isEmail(forgotEmailC.text)) {
      _showError('Masukkan email yang valid.');
      return;
    }

    await _runAuthAction(
      action: () => AuthService.to.forgotPassword(forgotEmailC.text),
      successMessage: 'Link reset password sudah dikirim.',
      onSuccess: Get.back,
    );
  }

  Future<void> logout() async {
    await AuthService.to.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> _runAuthAction({
    required Future<dynamic> Function() action,
    required String successMessage,
    required VoidCallback onSuccess,
  }) async {
    try {
      isLoading.value = true;
      await action();
      _showSuccess(successMessage); 
      onSuccess();
    } on FirebaseAuthException catch (error) {
      _showError(_authMessage(error));
    } catch (error) {
      _showError('Terjadi kesalahan: $error');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isEmail(String value) => GetUtils.isEmail(value.trim());

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'operation-not-allowed':
        return 'Email/Password belum diaktifkan.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      default:
        return '${error.code}: ${error.message ?? 'Autentikasi gagal.'}';
    }
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      borderRadius: 15,
      margin: const EdgeInsets.all(16),
      borderColor: Colors.amberAccent,
      borderWidth: 2,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.amber, size: 30),
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
      ],
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Perhatian',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      borderRadius: 15,
      margin: const EdgeInsets.all(16),
      borderColor: Colors.redAccent.shade100,
      borderWidth: 2,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 30),
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
      ],
    );
  }

  @override
  void onClose() {
    loginEmailC.dispose();
    loginPasswordC.dispose();
    registerEmailC.dispose();
    registerPasswordC.dispose();
    registerConfirmPasswordC.dispose();
    forgotEmailC.dispose();
    super.onClose();
  }
}