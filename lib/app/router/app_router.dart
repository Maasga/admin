import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/products/presentation/screens/mediatheque_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/clients/presentation/screens/clients_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/banners/presentation/screens/banners_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_screen.dart';
import '../../features/sav/presentation/screens/sav_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/devis/presentation/screens/devis_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/realisations/presentation/screens/realisations_screen.dart';
import '../../features/audit/presentation/screens/audit_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../shell/admin_shell.dart';
import '../../features/auth/data/providers/firebase_provider.dart';
import '../../features/auth/data/providers/admin_role_provider.dart';

/// Écran d'attente affiché tant que le rôle admin n'est pas confirmé.
const checkingRoleRoute = '/verification';

/// Logique de redirection pure (testable).
/// SÉCURITÉ : tant que le rôle est en cours de vérification, aucun écran admin
/// n'est accessible (auparavant un non-admin connecté y accédait brièvement).
String? computeAdminRedirect({
  required String location,
  required bool isAuthenticated,
  required bool isRoleLoading,
  required bool isAdmin,
}) {
  final isLoggingIn = location == '/login';
  final isUnauthorized = location == '/unauthorized';
  final isChecking = location == checkingRoleRoute;

  // 1. Non authentifié → /login
  if (!isAuthenticated) return isLoggingIn ? null : '/login';

  // 2. Rôle en cours de vérification → écran d'attente
  if (isRoleLoading) return isChecking ? null : checkingRoleRoute;

  // 3. Rôle résolu non-admin → /unauthorized
  if (!isAdmin) return isUnauthorized ? null : '/unauthorized';

  // 4. Admin sur un écran transitoire → tableau de bord
  if (isLoggingIn || isUnauthorized || isChecking) return '/dashboard';
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final adminRoleState = ref.watch(adminRoleProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) => computeAdminRedirect(
      location: state.matchedLocation,
      isAuthenticated: authState.value != null,
      isRoleLoading: adminRoleState.isLoading,
      isAdmin: adminRoleState.value ?? false,
    ),
    routes: [
      GoRoute(
        path: checkingRoleRoute,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/unauthorized',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const UnauthorizedScreen()),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(
            title: 'Tableau de bord',
            child: const DashboardScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/commandes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Commandes', child: const OrdersScreen()),
        ),
      ),
      GoRoute(
        path: '/rdv',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(
            title: 'Rendez-vous',
            child: const AppointmentsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/produits',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Produits', child: const ProductsScreen()),
        ),
      ),
      GoRoute(
        path: '/mediatheque',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(
            title: 'Médiathèque de groupe',
            child: const MediathequeScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(
            title: 'Notifications',
            child: const NotificationsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/devis',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Devis', child: const DevisScreen()),
        ),
      ),
      GoRoute(
        path: '/paiements',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Paiements', child: const PaymentsScreen()),
        ),
      ),
      GoRoute(
        path: '/clients',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Clients', child: const ClientsScreen()),
        ),
      ),
      GoRoute(
        path: '/maintenance',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(
            title: 'Maintenance',
            child: const MaintenanceScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/sav',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'SAV', child: const SAVScreen()),
        ),
      ),
      GoRoute(
        path: '/messages',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Messages', child: const MessagesScreen()),
        ),
      ),
      GoRoute(
        path: '/avis',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Avis', child: const ReviewsScreen()),
        ),
      ),
      GoRoute(
        path: '/realisations',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(
            title: 'Réalisations',
            child: const RealisationsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/banners',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Bannières', child: const BannersScreen()),
        ),
      ),
      GoRoute(
        path: '/audit',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Audit', child: const AuditScreen()),
        ),
      ),
      GoRoute(
        path: '/parametres',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: AdminShell(title: 'Paramètres', child: const SettingsScreen()),
        ),
      ),
    ],
  );
});
