import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_provider.dart';

/// Emails administrateurs explicites (fallback tant que le custom claim n'est pas posé).
/// SÉCURITÉ : jamais de règle par suffixe de domaine (n'importe qui peut créer un
/// compte Firebase `x@maasga.com`), et l'email doit être vérifié par Firebase.
/// Le backend applique la même règle (`isMobileAdminPayload`).
const adminEmailAllowlist = {'maasgabf@gmail.com', 'sawadogosherifhamed@gmail.com'};

/// Règle pure (testable) : l'utilisateur est-il administrateur ?
bool isAdminFromClaims(
  Map<String, dynamic>? claims, {
  String? email,
  bool emailVerified = false,
}) {
  final role = claims?['role'];
  final isAdminClaim = claims?['admin'];
  if (role == 'admin' || role == 'superadmin' || isAdminClaim == true || isAdminClaim == 1) {
    return true;
  }
  final normalized = email?.toLowerCase().trim();
  return emailVerified && normalized != null && adminEmailAllowlist.contains(normalized);
}

/// Provider vérifiant si l'utilisateur connecté détient les droits 'admin'
final adminRoleProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;

  try {
    // Obtenir le token avec ses custom claims à jour (forceRefresh: true)
    final tokenResult = await user.getIdTokenResult(true);
    return isAdminFromClaims(
      tokenResult.claims,
      email: user.email,
      emailVerified: user.emailVerified,
    );
  } catch (e) {
    return false;
  }
});
