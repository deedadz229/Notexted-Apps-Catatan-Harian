import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/theme_service.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),

              // STACK
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [

                  // CARD LOGIN
                  Container(
                    margin: const EdgeInsets.only(top: 55),
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      70,
                      24,
                      24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: AppTheme.greyText,
                                height: 1.35,
                              ),
                        ),

                        const SizedBox(height: 30),

                        ...children,
                      ],
                    ),
                  ),

                  // LOTTIE ATAS
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 420,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 237, 175),
                        borderRadius:
                            BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Lottie.asset(
                        'assets/login.json',
                        height: 110,
                        repeat: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}