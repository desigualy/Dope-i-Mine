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
import '../../app/post_auth_route.dart';
import 'auth_controller.dart';
import '../core/widgets/dopei_guide.dart';

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
  bool _obscurePassword = true;

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

    final targetRoute = await resolvePostAuthRoute(ref, authUser);

    if (!mounted) return;
    context.go(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Log in',
      child: ListView(
        children: <Widget>[
          const DopeiGuide(
            text:
                'Welcome back! Let’s get you signed in so we can tackle some tasks together.',
            mood: DopeiMood.calm,
          ),
          const SizedBox(height: 32),
          if (_errorText != null) ...<Widget>[
            ErrorBanner(message: _errorText!),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: AppTextField(
              controller: _emailController,
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: AppTextField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
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
                validateLoginPassword(_passwordController.text);
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

                final targetRoute = await resolvePostAuthRoute(ref, authUser);

                if (mounted) {
                  context.go(targetRoute);
                }
              } catch (error) {
                setState(() => _errorText = mapToUserFacingError(error));
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: const Text('Forgot password?'),
              ),
              TextButton(
                onPressed: () => context.go('/signup'),
                child: const Text('Create account'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
