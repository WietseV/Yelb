import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../data/workout_data.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../../firebase_options.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> goToHomePage() async {
    final workoutData = context.read<WorkoutData>();
    if (FirebaseAuth.instance.currentUser == null) {
      await workoutData.enableGuestMode();
    } else {
      workoutData.disableGuestMode();
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (!(Platform.isIOS || Platform.isAndroid)) {
        throw UnsupportedError('Google Sign-In only works on mobile.');
      }

      final googleSignIn = GoogleSignIn(
        clientId: (Platform.isIOS || Platform.isMacOS)
            ? DefaultFirebaseOptions.currentPlatform.iosClientId
            : null,
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await goToHomePage();
    } on UnsupportedError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? e.toString())),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign in failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
          body: Theme(
              data: ThemeData(canvasColor: AppColors.translucentAccent),
              child: AppGradientBackground(
                padding: const EdgeInsets.only(
                  top: 180,
                  left: 60,
                  right: 60,
                  bottom: 30,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.transparent,
                                AppColors.background
                              ],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Y.E.L.B.',
                            style: TextStyle(
                              color: AppColors.white38,
                              fontSize: 48,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 101),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 34, vertical: 13),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _signInWithGoogle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: AppColors.neutralSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: AppColors.shadowSoft,
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(Icons.g_mobiledata,
                                        color: Colors.redAccent, size: 24),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Sign in with Google',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.neutralText,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => goToHomePage(),
                      child: Text(
                        'Continue without an account',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
}
