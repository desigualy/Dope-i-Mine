import 'package:dope_i_mine/app/post_auth_route.dart';
import 'package:dope_i_mine/data/repositories/profile_repository_impl.dart';
import 'package:dope_i_mine/domain/auth/auth_user.dart';
import 'package:dope_i_mine/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository extends Fake implements ProfileRepositoryImpl {
  _FakeProfileRepository({
    required this.accountType,
    required this.onboardingComplete,
    this.mustChange = false,
  });

  final String accountType;
  final bool onboardingComplete;
  final bool mustChange;

  @override
  Future<void> ensureProfileExists({
    required String userId,
    String? email,
    String accountType = 'user',
  }) async {}

  @override
  Future<String> getAccountType(String userId) async => accountType;

  @override
  Future<bool> isOnboardingComplete(String userId) async => onboardingComplete;

  @override
  Future<bool> mustChangePassword(String userId) async => mustChange;
}

class _FakeWidgetRef extends Fake implements WidgetRef {
  _FakeWidgetRef(this.container);

  final ProviderContainer container;

  @override
  T read<T>(ProviderListenable<T> provider) => container.read(provider);
}

void main() {
  Future<String> routeFor(_FakeProfileRepository repository) async {
    final container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return resolvePostAuthRoute(
      _FakeWidgetRef(container),
      const AuthUser(id: 'user-a', email: 'user@example.com'),
    );
  }

  test('normal user routes home after setup', () async {
    expect(
      await routeFor(
        _FakeProfileRepository(
          accountType: 'user',
          onboardingComplete: true,
        ),
      ),
      '/home',
    );
  });

  test('onboarding incomplete user routes onboarding', () async {
    expect(
      await routeFor(
        _FakeProfileRepository(
          accountType: 'user',
          onboardingComplete: false,
        ),
      ),
      '/branding/intro',
    );
  });

  test('unconfirmed caregiver routes caregiver confirmation', () async {
    expect(
      await routeFor(
        _FakeProfileRepository(
          accountType: 'caregiver',
          onboardingComplete: false,
        ),
      ),
      '/caregiver/confirm',
    );
  });

  test('confirmed caregiver routes caregiver dashboard', () async {
    expect(
      await routeFor(
        _FakeProfileRepository(
          accountType: 'caregiver',
          onboardingComplete: true,
        ),
      ),
      '/caregiver',
    );
  });

  test('force-password-change route takes priority', () async {
    expect(
      await routeFor(
        _FakeProfileRepository(
          accountType: 'caregiver',
          onboardingComplete: true,
          mustChange: true,
        ),
      ),
      '/force-password-change',
    );
  });

  test('normal user never routes caregiver confirmation', () async {
    expect(
      await routeFor(
        _FakeProfileRepository(
          accountType: 'user',
          onboardingComplete: true,
        ),
      ),
      isNot('/caregiver/confirm'),
    );
  });

  group('ProfileRepositoryImpl.resolveEffectiveAccountType', () {
    test('does not trust stored caregiver account_type by itself', () {
      expect(
        ProfileRepositoryImpl.resolveEffectiveAccountType(
          storedAccountType: 'caregiver',
          requestedAccountType: null,
          hasCaregiverProfile: false,
          hasAcceptedCaregiverRelationship: false,
          hasAcceptedSupportedUserRelationship: false,
        ),
        'user',
      );
    });

    test('keeps supported users as normal users', () {
      expect(
        ProfileRepositoryImpl.resolveEffectiveAccountType(
          storedAccountType: 'caregiver',
          requestedAccountType: null,
          hasCaregiverProfile: false,
          hasAcceptedCaregiverRelationship: false,
          hasAcceptedSupportedUserRelationship: true,
        ),
        'user',
      );
    });

    test('promotes only explicit caregiver proof', () {
      expect(
        ProfileRepositoryImpl.resolveEffectiveAccountType(
          storedAccountType: 'user',
          requestedAccountType: 'caregiver',
          hasCaregiverProfile: false,
          hasAcceptedCaregiverRelationship: false,
          hasAcceptedSupportedUserRelationship: false,
        ),
        'caregiver',
      );

      expect(
        ProfileRepositoryImpl.resolveEffectiveAccountType(
          storedAccountType: 'user',
          requestedAccountType: null,
          hasCaregiverProfile: false,
          hasAcceptedCaregiverRelationship: true,
          hasAcceptedSupportedUserRelationship: false,
        ),
        'caregiver',
      );
    });
  });
}
