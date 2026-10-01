import 'registered_account.dart';

/// Provider workspace records are held locally for this prototype session.
class ProviderProfileData {
  String businessName = '';
  String description = '';
  String location = '';
  bool active = false;
  bool recordValid = false;
  bool documentsValid = false;
  DateTime? documentExpiry;
  int capacity = 0;
  bool departureChecksComplete = false;

  bool get complete => businessName.trim().isNotEmpty;

  bool get documentExpired {
    final expiry = documentExpiry;
    if (expiry == null) return false;
    final today = DateTime.now();
    return DateTime(expiry.year, expiry.month, expiry.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  bool get bookingEligible =>
      complete &&
      active &&
      recordValid &&
      documentsValid &&
      documentExpiry != null &&
      !documentExpired &&
      capacity > 0 &&
      departureChecksComplete;

  String get documentStatus {
    if (!complete || !documentsValid || documentExpiry == null)
      return 'PENDING';
    if (documentExpired) return 'EXPIRED';
    return 'VALID';
  }

  String get unavailableReason {
    if (!complete) return 'Complete your provider profile.';
    if (!active) return 'Provider status is inactive.';
    if (!recordValid) return 'Required provider record is incomplete.';
    if (!documentsValid || documentExpiry == null) {
      return 'Required provider documents are incomplete.';
    }
    if (documentExpired) {
      return 'Required provider document has expired.';
    }
    if (capacity < 1) return 'No capacity is currently available.';
    if (!departureChecksComplete) {
      return 'Required departure checks are incomplete.';
    }
    return '';
  }

  String get status {
    if (!complete) return 'PROFILE SETUP REQUIRED';
    if (bookingEligible) return 'BOOKING ELIGIBLE';
    if (active && documentStatus != 'EXPIRED') return 'PENDING REVIEW';
    return 'BOOKING UNAVAILABLE';
  }
}

class ProviderExperienceData {
  ProviderExperienceData({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.capacity,
    required this.includes,
    required this.cancellationPolicy,
    required this.category,
    this.active = true,
  });

  final String id;
  String title;
  String description;
  String location;
  int price;
  int capacity;
  String includes;
  String cancellationPolicy;
  String category;
  bool active;
}

class ProviderWorkspaceData {
  ProviderWorkspaceData(this.account);

  final RegisteredAccount account;
  final profile = ProviderProfileData();
  final experiences = <ProviderExperienceData>[];

  static final Map<String, ProviderWorkspaceData> _byAccount = {};

  static ProviderWorkspaceData forAccount(RegisteredAccount account) =>
      _byAccount.putIfAbsent(account.id, () => ProviderWorkspaceData(account));
}
