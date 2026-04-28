import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/auth_validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/async_action_button.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/primary_scaffold.dart';
import '../../providers.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorText;
  bool _redirectChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_redirectChecked) return;
    _redirectChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectIfAlreadyAuthenticated();
    });
  }

  Future<void> _redirectIfAlreadyAuthenticated() async {
    final authUser = ref.read(authRepositoryProvider).getCurrentUser();
    if (authUser == null || !mounted) return;

    final profileRepository = ref.read(profileRepositoryProvider);
    await profileRepository.ensureProfileExists(
      userId: authUser.id,
      email: authUser.email,
    );
    final onboardingComplete =
        await profileRepository.isOnboardingComplete(authUser.id);

    if (!mounted) return;
    context.go(onboardingComplete ? '/home' : '/branding/intro');
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Log in',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          AppTextField(controller: _emailController, hintText: 'Email'),
          const SizedBox(height: 12),
          AppTextField(controller: _passwordController, hintText: 'Password'),
          const SizedBox(height: 16),
          AsyncActionButton(
            label: 'Log in',
            loading: _loading,
            onPressed: () async {
              setState(() {
                _loading = true;
                _errorText = null;
              });
              try {
                validateEmail(_emailController.text);
                validatePassword(_passwordController.text);
                final signedInUser =
                    await ref.read(authControllerProvider).signIn(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );

                final authUser = signedInUser ??
                    ref.read(authRepositoryProvider).getCurrentUser();
                if (authUser == null) {
                  throw StateError(
                      'Signed in successfully, but no authenticated user is available.');
                }

                final profileRepository = ref.read(profileRepositoryProvider);
                await profileRepository.ensureProfileExists(
                  userId: authUser.id,
                  email: authUser.email,
                );
                final onboardingComplete =
                    await profileRepository.isOnboardingComplete(authUser.id);

                if (mounted) {
                  context.go(onboardingComplete ? '/home' : '/branding/intro');
                }
              } catch (error) {
                setState(() => _errorText = mapToUserFacingError(error));
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
          ),
          TextButton(
            onPressed: () => context.go('/signup'),
            child: const Text('Create account'),
          ),
        ],
      ),
    );
  }
}
