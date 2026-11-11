import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_admin/app/router/app_router.dart';
import 'package:mobile_admin/features/auth/data/providers/admin_role_provider.dart';
import 'package:mobile_admin/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('isAdminFromClaims', () {
    test('accepte role=admin / superadmin / admin=true / admin=1', () {
      expect(isAdminFromClaims({'role': 'admin'}), isTrue);
      expect(isAdminFromClaims({'role': 'superadmin'}), isTrue);
      expect(isAdminFromClaims({'admin': true}), isTrue);
      expect(isAdminFromClaims({'admin': 1}), isTrue);
    });

    test('refuse un email @maasga.com / @maasga.bf sans claim (même vérifié)', () {
      expect(isAdminFromClaims({}, email: 'pirate@maasga.com', emailVerified: true), isFalse);
      expect(isAdminFromClaims({}, email: 'pirate@maasga.bf', emailVerified: true), isFalse);
    });

    test('email de la liste explicite : accepté seulement si vérifié', () {
      expect(isAdminFromClaims(null, email: 'MaasgaBF@gmail.com ', emailVerified: true), isTrue);
      expect(isAdminFromClaims(null, email: 'maasgabf@gmail.com', emailVerified: false), isFalse);
    });

    test('refuse un client', () {
      expect(isAdminFromClaims({'role': 'client'}, email: 'c@gmail.com', emailVerified: true), isFalse);
    });
  });

  group('computeAdminRedirect', () {
    String? r(String loc, {bool auth = true, bool loading = false, bool admin = false}) =>
        computeAdminRedirect(location: loc, isAuthenticated: auth, isRoleLoading: loading, isAdmin: admin);

    test('non connecté → /login', () {
      expect(r('/dashboard', auth: false), '/login');
      expect(r('/login', auth: false), isNull);
    });

    test('rôle en cours de vérification → écran d\'attente (aucun écran admin accessible)', () {
      expect(r('/commandes', loading: true), checkingRoleRoute);
      expect(r('/clients', loading: true), checkingRoleRoute);
      expect(r(checkingRoleRoute, loading: true), isNull);
    });

    test('non admin → /unauthorized', () {
      expect(r('/dashboard'), '/unauthorized');
      expect(r(checkingRoleRoute), '/unauthorized');
      expect(r('/unauthorized'), isNull);
    });

    test('admin : accès libre, écrans transitoires → /dashboard', () {
      expect(r('/commandes', admin: true), isNull);
      expect(r('/login', admin: true), '/dashboard');
      expect(r('/unauthorized', admin: true), '/dashboard');
      expect(r(checkingRoleRoute, admin: true), '/dashboard');
    });
  });

  group('loginErrorMessage', () {
    test('ne divulgue jamais l\'exception brute', () {
      final msg = loginErrorMessage(Exception('[firebase_auth/user-not-found] secret detail uid=123'));
      expect(msg, 'Email ou mot de passe incorrect.');
      expect(loginErrorMessage(FirebaseAuthException(code: 'user-not-found')), 'Email ou mot de passe incorrect.');
      expect(loginErrorMessage(FirebaseAuthException(code: 'wrong-password')), 'Email ou mot de passe incorrect.');
    });

    test('messages spécifiques non sensibles', () {
      expect(loginErrorMessage(FirebaseAuthException(code: 'too-many-requests')), contains('Trop de tentatives'));
    });
  });
}
