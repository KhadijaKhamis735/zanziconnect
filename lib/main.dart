import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'models/registered_account.dart';
import 'screens/role_dashboard_screen.dart';
import 'screens/provider_workspace_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/explore_screen.dart';

const ocean = Color(0xff07509a),
    teal = Color(0xff087fb8),
    sand = Color(0xfff5f2ea),
    ink = Color(0xff17343a);
const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api');
void main() => runApp(const ZanziApp());

class DemoBooking {
  String? id;
  String? passport;
  String? complaintId;
  int? experienceId;
  String? experienceTitle;
  String? providerName;
  String? location;
  DateTime? experienceDate;
  int? guests;
  int? totalAmount;
  String status = 'UPCOMING';
  String complaint = 'NONE';
  String settlement = 'PENDING';
  bool booked = false;
}

class ZanziApp extends StatefulWidget {
  const ZanziApp({super.key});
  @override
  State<ZanziApp> createState() => _ZanziAppState();
}

class _ZanziAppState extends State<ZanziApp> {
  int tab = 0;
  bool providerMode = false;
  RegisteredAccount? authenticatedUser = DemoAccountStore.currentSession;
  bool hasStarted = DemoAccountStore.currentSession != null;
  final Map<String, DemoBooking> _demoBookingsByVisitor = {};
  DemoBooking get booking => _demoBookingsByVisitor.putIfAbsent(
      authenticatedUser?.id ?? 'anonymous', DemoBooking.new);
  void update() => setState(() {});
  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZanziConnect',
      theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: sand,
          colorScheme: ColorScheme.fromSeed(
              seedColor: teal, primary: teal, surface: sand),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
              backgroundColor: sand, foregroundColor: ink, elevation: 0)),
      home: !hasStarted
          ? WelcomeScreen(
              onAuthenticated: _onAuthenticated,
            )
          : authenticatedUser?.role == AccountRole.provider
              ? ProviderWorkspaceScreen(
                  account: authenticatedUser!,
                  onLogout: _logout,
                )
              : authenticatedUser?.role == AccountRole.admin
                  ? AdminDashboard(
                      account: authenticatedUser!,
                      onLogout: _logout,
                    )
                  : _visitorApplication());

  Widget _visitorApplication() => Scaffold(
        body: SafeArea(
          child: IndexedStack(index: tab, children: [
            HomeScreen(open: (i) => setState(() => tab = i), booking: booking),
            ExploreScreen(
              book: _book,
              bookedExperienceId: booking.booked ? booking.experienceId : null,
              passport: () => setState(() => tab = 3),
            ),
            TripsScreen(
              booking: booking,
              passport: () => setState(() => tab = 3),
              explore: () => setState(() => tab = 1),
            ),
            PassportScreen(
              booking: booking,
              notify: update,
              book: (context) => _book(context, demoEligibleExperience),
              explore: () => setState(() => tab = 1),
              trips: () => setState(() => tab = 2),
            ),
            ProfileScreen(
              providerMode: providerMode,
              toggle: () => setState(() => providerMode = !providerMode),
              booking: booking,
              changed: update,
              user: authenticatedUser,
              onLogout: authenticatedUser == null ? null : _logout,
            ),
          ]),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.waves_outlined), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.explore_outlined), label: 'Explore'),
            NavigationDestination(
                icon: Icon(Icons.luggage_outlined), label: 'My Trips'),
            NavigationDestination(
                icon: Icon(Icons.badge_outlined), label: 'Passport'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      );

  void _onAuthenticated(RegisteredAccount account) {
    setState(() {
      authenticatedUser = account;
      hasStarted = true;
      tab = 0;
      providerMode = false;
    });
  }

  void _logout() {
    DemoAccountStore.logout();
    setState(() {
      authenticatedUser = null;
      hasStarted = false;
      tab = 0;
      providerMode = false;
    });
  }

  Future<void> _book(BuildContext context, ExploreExperience experience) async {
    final name = TextEditingController(text: 'Demo Visitor'),
        phone = TextEditingController(),
        email = TextEditingController();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text('Book ${experience.title}'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: name,
                      decoration:
                          const InputDecoration(labelText: 'Customer name')),
                  TextField(
                      controller: phone,
                      decoration: const InputDecoration(labelText: 'Phone')),
                  TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  Text(
                      'TZS ${experience.price} · ${experience.guests} guests\nPayment: DEMO / SIMULATED',
                      style: const TextStyle(height: 1.5))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('CANCEL')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('CONFIRM DEMO BOOKING'))
                ]));
    if (accepted != true || !context.mounted) return;
    final experienceDate = DateTime.now().add(const Duration(days: 2));
    try {
      final response = await http
          .post(Uri.parse('$apiBaseUrl/bookings/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'experience_id': experience.id,
                'customer_name': name.text,
                'phone': phone.text,
                'email': email.text,
                'guests': experience.guests,
                'experience_date':
                    experienceDate.toIso8601String().substring(0, 10)
              }))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode >= 400)
        throw Exception(jsonDecode(response.body)['error'] ??
            'Booking could not be completed.');
      final data = jsonDecode(response.body);
      booking.id = '${data['id']}';
      booking.passport = data['passport_code'];
    } catch (_) {
      final visitorSuffix = authenticatedUser?.id.split('-').last ?? 'GUEST';
      booking.passport = 'ZC-DEMO-$visitorSuffix';
      booking.id = 'demo-$visitorSuffix';
    }
    booking.booked = true;
    booking.experienceId = experience.id;
    booking.experienceTitle = experience.title;
    booking.providerName = experience.provider;
    booking.location = experience.location;
    booking.experienceDate = experienceDate;
    booking.guests = experience.guests;
    booking.totalAmount = experience.price;
    update();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Demo booking confirmed · TZS ${experience.price}')));
      setState(() => tab = 3);
    }
  }
}

class ShellPage extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const ShellPage(this.title, {required this.child, this.trailing, super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverAppBar(
            pinned: true,
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            actions: [
              const DemoBadge(),
              if (trailing != null) trailing!,
              const SizedBox(width: 14)
            ]),
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            sliver: SliverToBoxAdapter(child: child))
      ]);
}

class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xffe6efeb),
          borderRadius: BorderRadius.circular(20)),
      child: const Text('DEMO MODE',
          style: TextStyle(
              color: ocean,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1)));
}

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> open;
  final DemoBooking booking;
  const HomeScreen({required this.open, required this.booking, super.key});

  @override
  Widget build(BuildContext context) => ShellPage(
        'ZanziConnect',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _homeHero(),
                const SizedBox(height: 30),
                _passportFeature(),
                const SizedBox(height: 30),
                _featuredExperience(context),
                const SizedBox(height: 30),
                _whyZanziConnect(context),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );

  Widget _homeHero() => LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 880;
        return Container(
          padding: EdgeInsets.all(desktop ? 36 : 25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff073b62), Color(0xff087d91)],
            ),
          ),
          child: Stack(children: [
            Positioned(
              right: desktop ? 8 : -70,
              top: desktop ? -75 : -92,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .055),
                ),
              ),
            ),
            if (desktop)
              Row(children: [
                Expanded(child: _heroCopy(desktop)),
                const SizedBox(width: 30),
                Expanded(child: _heroPassportVisual()),
              ])
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heroCopy(desktop),
                  const SizedBox(height: 24),
                  _heroPassportVisual(),
                ],
              ),
          ]),
        );
      });

  Widget _heroCopy(bool desktop) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ZANZIBAR  •  TANZANIA',
              style: TextStyle(
                  color: Color(0xffffd99a),
                  fontSize: 10,
                  letterSpacing: 1.7,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Text('Discover. Book.\nExperience Zanzibar.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: desktop ? 39 : 33,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8)),
          const SizedBox(height: 13),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Text(
              'Coastal experiences, with a transaction record that stays connected.',
              style: TextStyle(
                  color: Color(0xffe0f2ee), fontSize: 14, height: 1.55),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => open(1),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('EXPLORE EXPERIENCES'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xffffc76a),
              foregroundColor: const Color(0xff12384d),
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.symmetric(horizontal: 19),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w900, letterSpacing: .55),
            ),
          ),
        ],
      );

  Widget _heroPassportVisual() => Container(
        constraints: const BoxConstraints(maxWidth: 390),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .18)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.badge_outlined, color: Color(0xffffd99a), size: 20),
            SizedBox(width: 9),
            Text('TRIP PASSPORT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4)),
          ]),
          const SizedBox(height: 16),
          const Text('One journey. One connected record.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          const Wrap(spacing: 8, runSpacing: 9, children: [
            _JourneyPill('CHECK'),
            _JourneyPill('BOOK'),
            _JourneyPill('EXPERIENCE'),
            _JourneyPill('RECORD'),
            _JourneyPill('SETTLE'),
          ]),
        ]),
      );

  Widget _passportFeature() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Trip Passport',
              style: TextStyle(
                  color: ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.35)),
          const SizedBox(height: 4),
          const Text('One connected record for your ZanziConnect journey.',
              style: TextStyle(color: Color(0xff63746f), fontSize: 13)),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .045),
                      blurRadius: 20,
                      offset: const Offset(0, 7))
                ]),
            child: LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth >= 740;
              final content = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(spacing: 7, runSpacing: 7, children: [
                      _PassportStage('CHECK'),
                      _StageArrow(),
                      _PassportStage('BOOK'),
                      _StageArrow(),
                      _PassportStage('EXPERIENCE'),
                      _StageArrow(),
                      _PassportStage('RECORD'),
                      _StageArrow(),
                      _PassportStage('SETTLE'),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                      booking.booked
                          ? 'Your trip details, experience status, complaints and settlement stay connected in one place.'
                          : 'When you book an eligible experience, checks, booking details, experience status, complaints and settlement connect to the same transaction.',
                      style: const TextStyle(
                          color: Color(0xff63746f), fontSize: 12, height: 1.5),
                    ),
                  ]);
              if (wide) {
                return Row(children: [
                  Expanded(child: content),
                  const SizedBox(width: 18),
                  TextButton.icon(
                    onPressed: () => open(3),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                    label: const Text('LEARN ABOUT TRIP PASSPORT'),
                    style: TextButton.styleFrom(
                        foregroundColor: ocean,
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                ]);
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => open(3),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                      label: const Text('LEARN ABOUT TRIP PASSPORT'),
                      style: TextButton.styleFrom(
                          foregroundColor: ocean,
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ]);
            }),
          ),
        ],
      );

  Widget _featuredExperience(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Featured Experiences',
              style: TextStyle(
                  color: ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.35)),
          const SizedBox(height: 4),
          const Text('Discover selected Zanzibar coastal experiences.',
              style: TextStyle(color: Color(0xff63746f), fontSize: 13)),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 20,
                      offset: const Offset(0, 7))
                ]),
            child: LayoutBuilder(builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 760;
              final visual = Container(
                height: desktop ? null : 175,
                constraints:
                    desktop ? const BoxConstraints(minHeight: 224) : null,
                decoration: BoxDecoration(
                  borderRadius: desktop
                      ? const BorderRadius.horizontal(left: Radius.circular(22))
                      : const BorderRadius.vertical(top: Radius.circular(22)),
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xff0a597b), Color(0xff35a9a6)]),
                ),
                child: Stack(children: [
                  Positioned(
                      right: 15,
                      top: 13,
                      child: Icon(Icons.wb_sunny_rounded,
                          size: 29,
                          color: Colors.white.withValues(alpha: .65))),
                  const Center(
                      child: Icon(Icons.sailing_rounded,
                          size: 92, color: Color(0xffe7f3e9))),
                  const Positioned(
                      left: 17,
                      bottom: 14,
                      child: Text('NUNGWI · ZANZIBAR',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w900))),
                ]),
              );
              final details = Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 6),
                            decoration: BoxDecoration(
                                color: const Color(0xffe8f4ee),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('BOOKING ELIGIBLE',
                                style: TextStyle(
                                    color: Color(0xff207653),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .55))),
                        const SizedBox(width: 8),
                        const Text('DEMO DATA',
                            style: TextStyle(
                                color: Color(0xff84918c),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: .8)),
                      ]),
                      const SizedBox(height: 13),
                      const Text('Sunset Dhow Cruise',
                          style: TextStyle(
                              color: ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.35)),
                      const SizedBox(height: 5),
                      const Text('Nungwi Blue Dhow',
                          style: TextStyle(
                              color: Color(0xff63746f), fontSize: 13)),
                      const SizedBox(height: 13),
                      const Wrap(spacing: 18, runSpacing: 8, children: [
                        _ExperienceFact(
                            Icons.location_on_outlined, 'Nungwi, Zanzibar'),
                        _ExperienceFact(Icons.people_outline, '2 guests'),
                      ]),
                      const SizedBox(height: 15),
                      Row(children: [
                        const Expanded(
                            child: Text('TZS 200,000',
                                style: TextStyle(
                                    color: ink,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900))),
                        OutlinedButton.icon(
                          onPressed: () => open(1),
                          icon:
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: const Text('VIEW EXPERIENCE'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: ocean,
                              side: const BorderSide(color: Color(0xffd8e4df)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 10)),
                        ),
                      ]),
                    ]),
              );
              return ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: desktop
                    ? Row(children: [
                        Expanded(flex: 4, child: visual),
                        Expanded(flex: 6, child: details)
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [visual, details]),
              );
            }),
          ),
        ],
      );

  Widget _whyZanziConnect(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 850
            ? 3
            : width >= 560
                ? 2
                : 1;
        final gap = 12.0;
        final itemWidth = (width - gap * (columns - 1)) / columns;
        final items = [
          const _WhyItem(Icons.subject_outlined, 'CLEAR BOOKING TERMS',
              'Understand what is included and the booking conditions.'),
          const _WhyItem(Icons.fact_check_outlined, 'REQUIRED CHECKS',
              'See whether records required for the booking process are valid.'),
          const _WhyItem(Icons.route_outlined, 'CONNECTED TRIP RECORD',
              'Keep your transaction journey connected through the Trip Passport.'),
        ];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Why ZanziConnect?',
              style: TextStyle(
                  color: ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.35)),
          const SizedBox(height: 13),
          Wrap(
              spacing: gap,
              runSpacing: gap,
              children: items
                  .map((item) => SizedBox(width: itemWidth, child: item))
                  .toList()),
          const SizedBox(height: 12),
          const Text(
              'ZanziConnect does not replace government certification or regulatory authorities.',
              style: TextStyle(
                  color: Color(0xff84918c), fontSize: 10, height: 1.45)),
        ]);
      });
}

class _JourneyPill extends StatelessWidget {
  final String label;
  const _JourneyPill(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(18)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .55)),
      );
}

class _PassportStage extends StatelessWidget {
  final String label;
  const _PassportStage(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: ocean,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: .45));
}

class _StageArrow extends StatelessWidget {
  const _StageArrow();

  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.arrow_forward_rounded, size: 13, color: teal);
}

class _ExperienceFact extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ExperienceFact(this.icon, this.text);

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: teal, size: 16),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(color: Color(0xff63746f), fontSize: 11)),
      ]);
}

class _WhyItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _WhyItem(this.icon, this.title, this.description);

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 115),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(17)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: const Color(0xffe8f1ed),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: teal, size: 18)),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: ocean,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .6)),
                const SizedBox(height: 5),
                Text(description,
                    style: const TextStyle(
                        color: Color(0xff63746f), fontSize: 11, height: 1.45)),
              ])),
        ]),
      );
}

class PassportScreen extends StatelessWidget {
  final DemoBooking booking;
  final VoidCallback notify;
  final Future<void> Function(BuildContext) book;
  final VoidCallback explore;
  final VoidCallback trips;

  const PassportScreen({
    required this.booking,
    required this.notify,
    required this.book,
    required this.explore,
    required this.trips,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ShellPage(
        'Trip Passport',
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: booking.booked
                ? _bookedPassport(context)
                : _eligiblePreview(context),
          ),
        ),
      );

  Widget _eligiblePreview(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('One connected record for your ZanziConnect experience.',
              style: TextStyle(
                  color: Color(0xff63746f), fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          _passportHero(context, isPreview: true),
          const SizedBox(height: 20),
          _bookingChecks(),
          const SizedBox(height: 20),
          _lifecycle(),
          const SizedBox(height: 18),
          _informationPanel(
            icon: Icons.info_outline_rounded,
            title: 'BOOKING ELIGIBLE',
            body: 'Required booking checks have passed for this transaction.',
          ),
          const SizedBox(height: 10),
          _disclaimer(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => book(context),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('BOOK THIS EXPERIENCE'),
            ),
          ),
        ],
      );

  Widget _bookedPassport(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('One connected record for your ZanziConnect experience.',
              style: TextStyle(
                  color: Color(0xff63746f), fontSize: 14, height: 1.5)),
          const SizedBox(height: 20),
          _passportHero(context),
          const SizedBox(height: 20),
          _bookingChecks(),
          const SizedBox(height: 20),
          _lifecycle(),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final activity = _activityRecord();
            final summary = _bookingSummary();
            return wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 3, child: activity),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: summary),
                  ])
                : Column(
                    children: [activity, const SizedBox(height: 14), summary]);
          }),
          const SizedBox(height: 16),
          if (booking.complaint != 'NONE') ...[
            _complaintPanel(),
            const SizedBox(height: 14),
          ],
          if (booking.status == 'COMPLETED' ||
              booking.settlement != 'PENDING') ...[
            _settlementPanel(),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 14),
          _disclaimer(),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton.icon(
              onPressed: trips,
              icon: const Icon(Icons.luggage_outlined),
              label: Text(booking.status == 'COMPLETED'
                  ? 'VIEW TRIP RECORD'
                  : 'VIEW BOOKING'),
            ),
            if (booking.status != 'COMPLETED')
              OutlinedButton.icon(
                onPressed: () {
                  _action(context, booking, 'complete');
                  notify();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('MARK EXPERIENCE COMPLETED'),
              ),
            if (booking.status == 'COMPLETED' &&
                booking.complaint == 'NONE' &&
                booking.settlement != 'SETTLED')
              OutlinedButton(
                onPressed: () async {
                  await _complaint(context, booking);
                  notify();
                },
                child: const Text('CREATE DEMO COMPLAINT'),
              ),
            if (booking.complaint == 'OPEN')
              OutlinedButton(
                onPressed: () async {
                  await _action(context, booking, 'resolve');
                  notify();
                },
                child: const Text('RESOLVE DEMO COMPLAINT'),
              ),
            if (booking.status == 'COMPLETED' &&
                booking.settlement != 'SETTLED' &&
                booking.complaint != 'OPEN')
              OutlinedButton(
                onPressed: () async {
                  await _action(context, booking, 'settle');
                  notify();
                },
                child: const Text('PROCESS DEMO SETTLEMENT'),
              ),
          ]),
        ],
      );

  Widget _passportHero(BuildContext context, {bool isPreview = false}) {
    final date = booking.experienceDate;
    final dateText = date == null ? 'Set when booked' : _date(date);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff082d50), Color(0xff075778), Color(0xff087f87)],
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x24043b50), blurRadius: 24, offset: Offset(0, 10))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('TRIP PASSPORT',
                    style: TextStyle(
                        color: Color(0xffa9ded3),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('TRANSACTION RECORD',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700)),
              ])),
          _passportBadge(isPreview ? 'BOOKING ELIGIBLE' : booking.status),
        ]),
        const SizedBox(height: 16),
        Text(
            isPreview
                ? 'Record created after booking'
                : (booking.passport ?? 'Trip record'),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(
            isPreview
                ? 'ELIGIBILITY PREVIEW · DEMO DATA'
                : 'DEMO DATA · BOOKING ${booking.booked ? 'CONFIRMED' : 'PENDING'}',
            style: const TextStyle(
                color: Color(0xffb7e6dd),
                fontSize: 9,
                letterSpacing: .8,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760
              ? 3
              : constraints.maxWidth >= 480
                  ? 2
                  : 1;
          final gap = 14.0;
          final cellWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          final facts = <(String, String)>[
            (
              'Experience',
              booking.experienceTitle ?? demoEligibleExperience.title
            ),
            (
              'Provider',
              booking.providerName ?? demoEligibleExperience.provider
            ),
            ('Location', booking.location ?? demoEligibleExperience.location),
            ('Experience date', dateText),
            ('Guests', booking.guests?.toString() ?? '2'),
            (
              'Gross booking',
              booking.totalAmount == null
                  ? 'TZS ${_money(demoEligibleExperience.price)}'
                  : 'TZS ${_money(booking.totalAmount!)}'
            ),
          ];
          return Wrap(
              spacing: gap,
              runSpacing: 16,
              children: facts
                  .map((fact) => SizedBox(
                        width: cellWidth,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fact.$1.toUpperCase(),
                                  style: const TextStyle(
                                      color: Color(0xffa9ded3),
                                      fontSize: 9,
                                      letterSpacing: .8,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(fact.$2,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.3,
                                      fontWeight: FontWeight.w700)),
                            ]),
                      ))
                  .toList());
        }),
        if (booking.booked) ...[
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('TRIP RECORD QR',
                      style: TextStyle(
                          color: Color(0xffa9ded3),
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text(
                      'Scan to reference this ZanziConnect transaction record.',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11, height: 1.45)),
                ])),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: QrImageView(
                  data:
                      'ZanziConnect Transaction Record · ${booking.passport ?? booking.id ?? 'record'}',
                  size: 90,
                  backgroundColor: Colors.white),
            ),
          ]),
          const SizedBox(height: 8),
          Text('Record: ${booking.passport ?? booking.id ?? '—'}',
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ]),
    );
  }

  Widget _bookingChecks() => _passportSection(
        title: 'Booking Checks',
        subtitle:
            'Checks required by ZanziConnect before enabling this booking.',
        child: Column(children: [
          _checkStatus('Provider booking eligibility', true,
              'Passed for this experience'),
          _checkStatus('Required documents', true,
              'Included in current eligible listing'),
          _checkStatus(
              'Capacity', true, 'Included in current eligible listing'),
          _checkStatus('Departure conditions', true,
              'Included in current eligible listing'),
          _checkStatus(
              'Customer details',
              booking.booked,
              booking.booked
                  ? 'Provided in booking'
                  : 'Confirmed during booking'),
        ]),
      );

  Widget _lifecycle() {
    final completed = booking.status == 'COMPLETED';
    final done = [
      true,
      booking.booked,
      completed,
      completed,
      booking.settlement == 'SETTLED'
    ];
    const names = ['CHECK', 'BOOK', 'DEPART', 'COMPLETE', 'SETTLE'];
    return _passportSection(
      title: 'Transaction Journey',
      subtitle: 'Progress reflects the current booking and Passport state.',
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: 680, child: _stepper(names, done)),
          );
        }
        return _stepper(names, done);
      }),
    );
  }

  Widget _stepper(List<String> names, List<bool> done) => Row(
        children: List.generate(
            names.length,
            (index) => Expanded(
                  child: Row(children: [
                    Column(children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor:
                            done[index] ? teal : const Color(0xffedf1ef),
                        child: Icon(
                            done[index]
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            size: 18,
                            color: done[index]
                                ? Colors.white
                                : const Color(0xff84938e)),
                      ),
                      const SizedBox(height: 7),
                      Text(names[index],
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: done[index]
                                  ? ocean
                                  : const Color(0xff84938e))),
                      const SizedBox(height: 3),
                      Text(done[index] ? 'Passed' : 'Pending',
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xff75837e))),
                    ]),
                    if (index < names.length - 1)
                      Expanded(
                          child: Container(
                              height: 2,
                              margin: const EdgeInsets.only(
                                  left: 8, right: 8, bottom: 28),
                              color: done[index + 1]
                                  ? teal
                                  : const Color(0xffdfe6e2))),
                  ]),
                )),
      );

  Widget _activityRecord() {
    final rows = <(String, bool)>[
      ('Provider eligibility checked', true),
      if (booking.booked)
        ('Booking confirmed · ${booking.id ?? 'record linked'}', true),
      if (booking.status == 'COMPLETED') ('Experience marked complete', true),
      if (booking.complaint != 'NONE')
        ('Complaint ${booking.complaint.toLowerCase()}', true),
      if (booking.settlement == 'SETTLED') ('Settlement processed', true),
    ];
    return _passportSection(
      title: 'Activity Record',
      subtitle:
          'Recorded transaction events. Timestamps are not available in this prototype.',
      child: Column(
          children: rows
              .map((row) => Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: teal, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(row.$1,
                                  style: const TextStyle(
                                      color: ink,
                                      fontSize: 13,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600))),
                        ]),
                  ))
              .toList()),
    );
  }

  Widget _bookingSummary() => _passportSection(
        title: 'Booking Summary',
        subtitle: 'Confirmed booking details',
        child: Column(children: [
          _summaryRow('Booking ID', booking.id ?? '—'),
          _summaryRow('Booking status', booking.status),
          _summaryRow(
              'Experience date',
              booking.experienceDate == null
                  ? '—'
                  : _date(booking.experienceDate!)),
          _summaryRow('Guests', '${booking.guests ?? '—'}'),
          _summaryRow(
              'Gross booking',
              booking.totalAmount == null
                  ? '—'
                  : 'TZS ${_money(booking.totalAmount!)}'),
        ]),
      );

  Widget _complaintPanel() => _informationPanel(
        icon: booking.complaint == 'OPEN'
            ? Icons.report_gmailerrorred_outlined
            : Icons.check_circle_outline,
        title: 'COMPLAINT ${booking.complaint}',
        body: booking.complaint == 'OPEN'
            ? 'Settlement is currently on hold while the complaint is unresolved.'
            : 'The recorded complaint has been resolved.',
      );

  Widget _settlementPanel() => _passportSection(
        title: 'Settlement',
        subtitle: 'Visitor transaction settlement status',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _passportBadge(booking.settlement),
          if (booking.settlement == 'SETTLED') ...[
            const SizedBox(height: 12),
            Text(
                'Gross TZS ${_money(booking.totalAmount ?? demoEligibleExperience.price)} · Commission TZS 20,000 · Provider allocation TZS 180,000',
                style: const TextStyle(
                    color: Color(0xff63746f), fontSize: 12, height: 1.5)),
          ],
        ]),
      );

  Widget _disclaimer() => const Text(
        'ZanziConnect checks records required for its booking process. It does not replace government certification, licensing, inspection or safety authorities.',
        style: TextStyle(fontSize: 11, color: Color(0xff63746f), height: 1.5),
      );

  Widget _passportSection(
          {required String title, String? subtitle, required Widget child}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xffe2e9e4))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: ocean,
                  fontSize: 11,
                  letterSpacing: .9,
                  fontWeight: FontWeight.w900)),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(subtitle,
                style: const TextStyle(
                    color: Color(0xff63746f), fontSize: 12, height: 1.45)),
          ],
          const SizedBox(height: 14),
          child,
        ]),
      );

  Widget _checkStatus(String label, bool passed, String detail) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Icon(passed ? Icons.check_circle_rounded : Icons.schedule_rounded,
              color: passed ? const Color(0xff20815b) : const Color(0xffbd7c2e),
              size: 19),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: ink, fontSize: 12, fontWeight: FontWeight.w700))),
          Flexible(
              child: Text(detail,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: passed
                          ? const Color(0xff39745c)
                          : const Color(0xffa26d30),
                      fontSize: 10))),
        ]),
      );

  Widget _summaryRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(label,
                  style:
                      const TextStyle(color: Color(0xff63746f), fontSize: 11))),
          const SizedBox(width: 12),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: ink, fontSize: 11, fontWeight: FontWeight.w800))),
        ]),
      );

  Widget _informationPanel(
          {required IconData icon,
          required String title,
          required String body}) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xffe9f4ef),
            borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: teal),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: ocean,
                        fontSize: 10,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        color: ink, fontSize: 12, height: 1.45)),
              ])),
        ]),
      );

  Widget _passportBadge(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: const Color(0xffd7f1e8),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label.toUpperCase(),
            style: const TextStyle(
                color: Color(0xff145b50),
                fontSize: 9,
                letterSpacing: .4,
                fontWeight: FontWeight.w900)),
      );

  String _date(DateTime date) => '${date.day} ${const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][date.month - 1]} ${date.year}';

  String _money(int value) => value
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

class TripsScreen extends StatefulWidget {
  final DemoBooking booking;
  final VoidCallback passport, explore;
  const TripsScreen(
      {required this.booking,
      required this.passport,
      required this.explore,
      super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isCompleted = booking.status == 'COMPLETED';
    final showTrip = booking.booked &&
        (_filter == 'All' ||
            (_filter == 'Completed' && isCompleted) ||
            (_filter == 'Upcoming' && !isCompleted));
    return ShellPage(
      'My Trips',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Track your bookings and follow each experience from booking to completion.',
                style: TextStyle(
                    color: Color(0xff63746f), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _tripFilter('All'),
                _tripFilter('Upcoming'),
                _tripFilter('Completed'),
              ]),
              const SizedBox(height: 20),
              if (showTrip)
                _tripCard(context, booking, isCompleted)
              else if (!booking.booked && _filter == 'All')
                _emptyTrips()
              else
                _noFilteredTrips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripFilter(String label) {
    final selected = _filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = label),
      selectedColor: ocean,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? ocean : const Color(0xffdce5e0)),
      labelStyle: TextStyle(
          color: selected ? Colors.white : ink, fontWeight: FontWeight.w700),
    );
  }

  Widget _emptyTrips() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xffe2e9e4)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x100b3d48), blurRadius: 22, offset: Offset(0, 8))
          ],
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 650;
          final art = Container(
            height: 190,
            width: wide ? 255 : double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffe3f3ee), Color(0xffeef4f2)]),
            ),
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                  right: 25,
                  top: 20,
                  child: Icon(Icons.route_rounded,
                      size: 42, color: teal.withValues(alpha: .22))),
              const Icon(Icons.luggage_rounded, size: 72, color: ocean),
              Positioned(
                  bottom: 17,
                  right: 20,
                  child: Icon(Icons.sailing_rounded,
                      size: 36, color: teal.withValues(alpha: .75))),
            ]),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('NO TRIPS YET',
                  style: TextStyle(
                      color: teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
              const SizedBox(height: 9),
              const Text('Your Zanzibar journey starts with an experience.',
                  style: TextStyle(
                      color: ink,
                      fontSize: 22,
                      height: 1.25,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 9),
              const Text(
                  'Explore coastal experiences and your bookings will appear here.',
                  style: TextStyle(color: Color(0xff63746f), height: 1.5)),
              const SizedBox(height: 18),
              FilledButton.icon(
                  onPressed: widget.explore,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('EXPLORE EXPERIENCES')),
            ],
          );
          return wide
              ? Row(children: [
                  art,
                  const SizedBox(width: 28),
                  Expanded(child: copy)
                ])
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [art, const SizedBox(height: 22), copy]);
        }),
      );

  Widget _noFilteredTrips() => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          const Icon(Icons.event_busy_outlined, color: teal, size: 38),
          const SizedBox(height: 10),
          Text('No ${_filter.toLowerCase()} trips',
              style: const TextStyle(fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 5),
          const Text('Your trip list will update when your booking changes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff63746f))),
        ]),
      );

  Widget _tripCard(BuildContext context, DemoBooking booking, bool completed) {
    final date = booking.experienceDate;
    final dateLabel = date == null
        ? 'Date not available'
        : '${_month(date.month)} ${date.day}, ${date.year}';
    final stages = [
      ('CHECK', true),
      ('BOOK', booking.booked),
      ('EXPERIENCE', completed),
      ('RECORD', completed),
      ('SETTLE', booking.settlement == 'SETTLED'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffe2e9e4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x100b3d48), blurRadius: 22, offset: Offset(0, 8))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 780;
        final visual = Container(
          height: wide ? null : 190,
          width: wide ? 270 : double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff0c5476), Color(0xff0a9694)]),
          ),
          child: Stack(children: [
            const Positioned(
                right: -8,
                bottom: -25,
                child: Icon(Icons.waves_rounded,
                    size: 150, color: Color(0x337fffff))),
            const Center(
                child:
                    Icon(Icons.sailing_rounded, size: 68, color: Colors.white)),
            Positioned(
              top: 14,
              left: 14,
              child: _statusPill(completed ? 'COMPLETED' : 'UPCOMING', true),
            ),
          ]),
        );
        final details = Padding(
          padding: const EdgeInsets.all(22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              _statusPill(booking.booked ? 'CONFIRMED' : booking.status, false),
              if (booking.complaint != 'NONE')
                _statusPill('COMPLAINT ${booking.complaint}', false),
              if (booking.settlement == 'SETTLED')
                _statusPill('SETTLED', false),
            ]),
            const SizedBox(height: 12),
            Text(booking.experienceTitle ?? 'Booked experience',
                style: const TextStyle(
                    color: ink,
                    fontSize: 23,
                    height: 1.2,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(booking.providerName ?? 'Provider not available',
                style: const TextStyle(
                    color: Color(0xff63746f), fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Wrap(spacing: 18, runSpacing: 12, children: [
              _tripFact(Icons.place_outlined,
                  booking.location ?? 'Location not available'),
              _tripFact(Icons.calendar_month_outlined, dateLabel),
              _tripFact(Icons.group_outlined, '${booking.guests ?? 2} guests'),
              if (booking.totalAmount != null)
                _tripFact(
                    Icons.payments_outlined, 'TZS ${booking.totalAmount}'),
              if (booking.passport != null)
                _tripFact(Icons.badge_outlined, 'Passport ${booking.passport}'),
            ]),
            const SizedBox(height: 20),
            const Text('TRANSACTION PROGRESS',
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                    color: ocean)),
            const SizedBox(height: 12),
            Wrap(
                spacing: 0,
                runSpacing: 10,
                children:
                    stages.map((stage) => _stage(stage.$1, stage.$2)).toList()),
            const SizedBox(height: 20),
            Wrap(spacing: 10, runSpacing: 10, children: [
              FilledButton.icon(
                onPressed: () => _showTripDetails(context, booking),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('VIEW TRIP'),
              ),
              OutlinedButton.icon(
                onPressed: widget.passport,
                icon: const Icon(Icons.badge_outlined),
                label: const Text('VIEW PASSPORT'),
              ),
            ]),
          ]),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [visual, Expanded(child: details)])
            : Column(children: [visual, details]);
      }),
    );
  }

  Widget _stage(String label, bool done) => SizedBox(
        width: 102,
        child: Row(children: [
          Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 17,
              color: done ? teal : const Color(0xffb5c3bf)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: done ? ink : const Color(0xff879692))),
        ]),
      );

  Widget _statusPill(String text, bool dark) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: dark ? Colors.white : const Color(0xffe6f3ef),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 9,
                letterSpacing: .4,
                fontWeight: FontWeight.w900,
                color: dark ? ocean : teal)),
      );

  Widget _tripFact(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 17, color: teal),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: ink, fontSize: 12, fontWeight: FontWeight.w600)),
      ]);

  void _showTripDetails(BuildContext context, DemoBooking booking) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking.experienceTitle ?? 'Trip details'),
        content: Text([
          booking.providerName ?? 'Provider not available',
          booking.location ?? 'Location not available',
          booking.experienceDate == null
              ? 'Date not available'
              : '${_month(booking.experienceDate!.month)} ${booking.experienceDate!.day}, ${booking.experienceDate!.year}',
          '${booking.guests ?? 2} guests · ${booking.status}',
        ].join('\n')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE')),
          FilledButton(
              onPressed: () {
                Navigator.pop(context);
                widget.passport();
              },
              child: const Text('OPEN PASSPORT')),
        ],
      ),
    );
  }

  String _month(int month) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ][month - 1];
}

class ProfileScreen extends StatelessWidget {
  final bool providerMode;
  final VoidCallback toggle;
  final VoidCallback changed;
  final DemoBooking booking;
  final RegisteredAccount? user;
  final VoidCallback? onLogout;

  const ProfileScreen({
    required this.providerMode,
    required this.toggle,
    required this.booking,
    required this.changed,
    this.user,
    this.onLogout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const DemoBadge(),
      const SizedBox(height: 16),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Provider Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          providerMode ? 'Nungwi Blue Dhow dashboard' : 'Visitor Mode',
        ),
        value: providerMode,
        onChanged: (_) => toggle(),
      ),
      const SizedBox(height: 18),
      _section('Why ZanziConnect'),
      const Text(
        'Tourism transactions can be fragmented across discovery, booking, communication, service delivery and settlement.',
        style: TextStyle(height: 1.5, color: Colors.black54),
      ),
      const SizedBox(height: 10),
      _card(
        context,
        Icons.route,
        'One transaction record',
        'DISCOVER → CHECK → BOOK → EXPERIENCE → RECORD → SETTLE',
      ),
      const SizedBox(height: 22),
      _section('Business model'),
      _info(
        'Booking commission',
        'Proposed 10% per completed booking. Final structure to be validated during the pilot.',
      ),
      _info(
        'Future revenue · PROPOSED',
        'Provider subscriptions, sponsored promotion and enterprise partnerships.',
      ),
      const SizedBox(height: 15),
      _section('90-day pilot · illustrative plan'),
      _info(
          'Days 1–20 · Validate', 'Provider selection, terms and operations.'),
      _info('Days 21–45 · Build & test',
          'Pilot platform, onboarding and testing.'),
      _info(
        'Days 46–75 · Controlled paid operations',
        'Track transactions, complaints, completion and settlement.',
      ),
      _info(
        'Days 76–90 · Evaluate',
        'Provider/customer feedback, unit economics and scale decision.',
      ),
      const SizedBox(height: 10),
      const AlertTile(
        text:
            'PILOT TARGET — NOT CURRENT RESULT\n10 access partners · 25 local suppliers · 150 paid bookings · 72 hour complaint resolution target',
      ),
      const SizedBox(height: 22),
      _section('Funding request'),
      const Text(
        'TZS 50 MILLION · REQUESTED FOR THE CONTROLLED 90-DAY PILOT',
        style: TextStyle(
          color: teal,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
      ...[
        'Product implementation — TZS 14,000,000',
        'Compliance & provider verification — TZS 6,000,000',
        'Customer support & operations — TZS 7,000,000',
        'Customer acquisition — TZS 8,000,000',
        'Working capital — TZS 6,000,000',
        'Refund / service recovery reserve — TZS 3,000,000',
        'Monitoring & evaluation — TZS 2,000,000',
        'Contingency — TZS 4,000,000',
      ].map((item) => _info(item, '')),
      const SizedBox(height: 18),
      _section('Tourism → Blue Economy'),
      const Text(
        'Connect eligible local tourism and coastal enterprises to visitor demand. Record booking value, provider allocation, commission, outcomes and settlement.',
        style: TextStyle(color: Colors.black54, height: 1.5),
      ),
      _info(
        'Phase 1 · Pilot focus',
        'Marine experiences · Dhow experiences · Tours · selected providers · referral partners',
      ),
      _info(
        'Phase 2 · Planned expansion',
        'Transport · food · culture · wellness · events · local products',
      ),
      _info(
        'Phase 3 · Planned expansion',
        'Wider coastal and Blue Economy participation',
      ),
      const SizedBox(height: 18),
      _section('Platform checks'),
      const Text(
        'ZanziConnect does not replace government certification, licensing, inspection or safety responsibilities.',
        style: TextStyle(color: Colors.black54, height: 1.5),
      ),
    ];

    if (providerMode) {
      children.insertAll(3, [
        const AlertTile(text: 'BOOKING ELIGIBLE · 1 upcoming demo booking'),
        _card(
          context,
          Icons.sailing,
          'Sunset Dhow Cruise',
          'TZS 200,000 · Illustrative demo calculation',
          onTap: () => _providerActions(context),
        ),
      ]);
    }
    if (user != null) {
      children.insertAll(0, [
        Card(
          color: Colors.white,
          child: ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: teal),
            title: Text(user!.fullName),
            subtitle: Text('${user!.email} · ${user!.role.apiValue}'),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('LOG OUT'),
          ),
        ),
      ]);
    }

    return ShellPage(
      'Profile & Pilot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void _providerActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Provider dashboard · ' + booking.status,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Gross TZS 200,000 · commission TZS 20,000 · provider TZS 180,000',
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _action(
                  context,
                  booking,
                  booking.status == 'COMPLETED' ? 'settle' : 'complete',
                );
                changed();
              },
              child: Text(
                booking.status == 'COMPLETED'
                    ? 'PROCESS DEMO SETTLEMENT'
                    : 'MARK EXPERIENCE COMPLETED',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _action(BuildContext context, DemoBooking b, String action) async {
  try {
    if (b.id != null) {
      final endpoint = action == 'resolve'
          ? 'complaints/${b.complaintId}/resolve/'
          : 'bookings/${b.id}/$action/';
      final res = await http
          .post(Uri.parse('$apiBaseUrl/$endpoint'))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode >= 400) throw Exception();
    }
  } catch (_) {}
  if (action == 'complete') {
    b.status = 'COMPLETED';
    b.settlement = 'ELIGIBLE';
  }
  if (action == 'resolve') {
    b.complaint = 'RESOLVED';
    b.settlement = 'ELIGIBLE';
  }
  if (action == 'settle') {
    b.settlement = 'SETTLED';
  }
  (context as Element).markNeedsBuild();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(action == 'settle'
          ? 'Illustrative demo settlement processed.'
          : 'Passport updated: ${action.toUpperCase()}')));
}

Future<void> _complaint(BuildContext context, DemoBooking b) async {
  try {
    if (b.id != null) {
      final r = await http
          .post(Uri.parse('$apiBaseUrl/bookings/${b.id}/complaints/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'description': 'Illustrative service issue'}))
          .timeout(const Duration(seconds: 2));
      if (r.statusCode < 300)
        b.complaintId = '${jsonDecode(r.body)['complaint_id']}';
    }
  } catch (_) {}
  b.complaint = 'OPEN';
  b.settlement = 'ON HOLD';
  (context as Element).markNeedsBuild();
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Demo complaint recorded · settlement on hold')));
}

Widget _section(String s) => Text(s.toUpperCase(),
    style: const TextStyle(
        color: ocean,
        fontSize: 12,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w900));
Widget _card(BuildContext c, IconData icon, String title, String sub,
        {VoidCallback? onTap}) =>
    Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(19),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  CircleAvatar(
                      backgroundColor: const Color(0xffe8f1ed),
                      child: Icon(icon, color: teal)),
                  const SizedBox(width: 13),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, color: ink)),
                        const SizedBox(height: 3),
                        Text(sub,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                height: 1.4))
                      ])),
                  const Icon(Icons.chevron_right, color: Colors.black38)
                ]))));
Widget _info(String title, String body) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w800, color: ink)),
          if (body.isNotEmpty)
            Text(body,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 12, height: 1.45))
        ])));

class AlertTile extends StatelessWidget {
  final String text;
  const AlertTile({required this.text, super.key});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xffffefdf),
          borderRadius: BorderRadius.circular(16)),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xff774b30),
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600)));
}
