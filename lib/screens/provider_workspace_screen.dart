import 'package:flutter/material.dart';

import '../models/provider_workspace_data.dart';
import '../models/registered_account.dart';

class ProviderWorkspaceScreen extends StatefulWidget {
  const ProviderWorkspaceScreen({
    required this.account,
    required this.onLogout,
    super.key,
  });

  final RegisteredAccount account;
  final VoidCallback onLogout;

  @override
  State<ProviderWorkspaceScreen> createState() =>
      _ProviderWorkspaceScreenState();
}

class _ProviderWorkspaceScreenState extends State<ProviderWorkspaceScreen> {
  static const _titles = [
    'Dashboard',
    'Experiences',
    'Bookings',
    'Settlements',
    'Profile',
  ];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.sailing_outlined,
    Icons.calendar_month_outlined,
    Icons.payments_outlined,
    Icons.person_outline,
  ];
  late final ProviderWorkspaceData data =
      ProviderWorkspaceData.forAccount(widget.account);
  final TextEditingController _experienceSearchController =
      TextEditingController();
  final TextEditingController _bookingSearchController =
      TextEditingController();
  String _experienceFilter = 'All';
  String _bookingFilter = 'All';
  int _index = 0;

  @override
  void dispose() {
    _experienceSearchController.dispose();
    _bookingSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final pages = [
        _dashboard(),
        _experiences(),
        _bookings(),
        _settlements(),
        _profile(),
      ];
      return Scaffold(
        backgroundColor: const Color(0xfff5f2ea),
        appBar: AppBar(
          title: const Text('ZanziConnect Provider'),
          actions: [
            const _PrototypeTag(),
            const SizedBox(width: 12),
            if (wide)
              TextButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('LOG OUT'),
              )
            else
              IconButton(
                tooltip: 'Log out',
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
              ),
            const SizedBox(width: 12),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: [
            for (var pageIndex = 0; pageIndex < pages.length; pageIndex++)
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    wide ? 34 : 18,
                    22,
                    wide ? 34 : 18,
                    pageIndex <= 3
                        ? (wide ? 64 : 88) +
                            MediaQuery.of(context).viewPadding.bottom
                        : wide
                            ? 40
                            : 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: pageIndex <= 3 ? 1280 : 1120),
                    child: pages[pageIndex],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: List.generate(
            _titles.length,
            (i) => NavigationDestination(
              key: Key('provider_navigation_$i'),
              icon: Icon(_icons[i]),
              label: _titles[i],
            ),
          ),
        ),
      );
    });
  }

  Widget _dashboard() {
    final readiness = _readinessItems();
    final completeCount = readiness.where((item) => item.$2).length;
    final readinessFraction = completeCount / readiness.length;
    final firstName =
        widget.account.fullName.trim().split(RegExp(r'\s+')).first;
    final nextStep = _nextStep();
    final journeyIndex = _journeyIndex();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Welcome back, $firstName',
          style: const TextStyle(
              fontSize: 15,
              color: Color(0xff61736f),
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 5),
      const Text('Provider Dashboard',
          style: TextStyle(
              color: Color(0xff07509a),
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5)),
      const SizedBox(height: 5),
      const Text('Manage your experiences, bookings and transaction activity.',
          style:
              TextStyle(color: Color(0xff61736f), fontSize: 14, height: 1.5)),
      const SizedBox(height: 22),
      _dashboardStatusCard(completeCount, readiness.length, readinessFraction),
      const SizedBox(height: 25),
      _sectionTitle('Overview'),
      const SizedBox(height: 11),
      LayoutBuilder(builder: (context, constraints) {
        final count = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 600
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
          childAspectRatio: count == 4
              ? 1.45
              : count == 2
                  ? 2.15
                  : 2.1,
          children: [
            _dashboardStat(
              title: 'Experiences',
              value: '${data.experiences.length}',
              detail: 'Your offered experiences',
              icon: Icons.sailing_outlined,
              onTap: () => _openTab(1),
            ),
            _dashboardStat(
              title: 'Upcoming bookings',
              value: '0',
              detail: 'Awaiting an experience',
              icon: Icons.event_available_outlined,
              onTap: () => _openTab(2),
            ),
            _dashboardStat(
              title: 'Completed bookings',
              value: '0',
              detail: 'Finished experiences',
              icon: Icons.task_alt_outlined,
              onTap: () => _openTab(2),
            ),
            _dashboardStat(
              title: 'Pending settlement',
              value: 'TZS 0',
              detail: 'Awaiting settlement',
              icon: Icons.payments_outlined,
              onTap: () => _openTab(3),
            ),
          ],
        );
      }),
      const SizedBox(height: 25),
      _sectionTitle('Quick Actions'),
      const SizedBox(height: 11),
      Wrap(spacing: 9, runSpacing: 9, children: [
        OutlinedButton.icon(
          onPressed: _addExperience,
          icon: const Icon(Icons.add_rounded),
          label: const Text('ADD EXPERIENCE'),
        ),
        OutlinedButton.icon(
          onPressed: () => _openTab(2),
          icon: const Icon(Icons.calendar_month_outlined),
          label: const Text('VIEW BOOKINGS'),
        ),
        OutlinedButton.icon(
          onPressed: () => _openTab(4),
          icon: const Icon(Icons.manage_accounts_outlined),
          label: const Text('MANAGE PROFILE'),
        ),
      ]),
      const SizedBox(height: 25),
      _sectionTitle('Your Next Step'),
      const SizedBox(height: 11),
      _nextStepCard(nextStep),
      const SizedBox(height: 25),
      _sectionTitle('Provider Journey'),
      const SizedBox(height: 11),
      _journeyCard(journeyIndex),
      const SizedBox(height: 25),
      _sectionTitle('Provider Readiness'),
      const SizedBox(height: 4),
      const Text(
          'Requirements that affect whether your experiences can accept bookings.',
          style:
              TextStyle(color: Color(0xff61736f), fontSize: 12, height: 1.5)),
      const SizedBox(height: 11),
      _readinessCard(readiness),
      const SizedBox(height: 13),
      _bookingReadinessInfo(),
      const SizedBox(height: 25),
      _sectionTitle('Recent Activity'),
      const SizedBox(height: 11),
      _emptyActivity(),
      const SizedBox(height: 14),
      const Text(
        'Provider profile and experience data are stored locally for this prototype session.',
        style: TextStyle(color: Color(0xff61736f), fontSize: 11),
      ),
    ]);
  }

  void _openTab(int index) => setState(() => _index = index);

  List<(String, bool, String)> _readinessItems() {
    final p = data.profile;
    final documentsComplete =
        p.documentsValid && p.documentExpiry != null && !p.documentExpired;
    return [
      (
        'Provider active status',
        p.active,
        p.active ? 'COMPLETE' : 'INCOMPLETE'
      ),
      (
        'Provider record',
        p.recordValid,
        p.recordValid ? 'COMPLETE' : 'INCOMPLETE'
      ),
      (
        'Required documents',
        documentsComplete,
        p.documentStatus == 'EXPIRED' ? 'EXPIRED' : p.documentStatus
      ),
      (
        'Capacity information',
        p.capacity > 0,
        p.capacity > 0 ? 'VALID · ${p.capacity} guests' : 'INCOMPLETE'
      ),
      (
        'Departure checks',
        p.departureChecksComplete,
        p.departureChecksComplete ? 'COMPLETE' : 'INCOMPLETE'
      ),
    ];
  }

  (String, String, String, IconData, VoidCallback) _nextStep() {
    if (!data.profile.complete) {
      return (
        'Complete your provider profile',
        'Add your provider information and required records to continue toward booking eligibility.',
        'COMPLETE PROFILE',
        Icons.storefront_outlined,
        _editProfile,
      );
    }
    if (data.experiences.isEmpty) {
      return (
        'Add your first experience',
        'Create an experience listing to start building your provider workspace.',
        'ADD EXPERIENCE',
        Icons.add_business_outlined,
        _addExperience,
      );
    }
    if (!data.profile.bookingEligible) {
      return (
        'Complete experience requirements',
        data.profile.unavailableReason,
        'REVIEW REQUIREMENTS',
        Icons.fact_check_outlined,
        _editProfile,
      );
    }
    return (
      'Your experiences are ready',
      'Your listings meet the current provider checks. New booking activity will appear in your workspace when available.',
      'VIEW EXPERIENCES',
      Icons.sailing_outlined,
      () => _openTab(1),
    );
  }

  int _journeyIndex() {
    if (!data.profile.complete) return 0;
    if (data.experiences.isEmpty) return 1;
    if (!data.profile.bookingEligible) return 2;
    return 3;
  }

  Widget _dashboardStatusCard(int complete, int total, double progress) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xfff5f0df), Color(0xfffffbf0)],
          ),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xffeadfbe)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xffefe4c4),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.assignment_ind_outlined,
                  color: Color(0xff856823)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(data.profile.status,
                      style: const TextStyle(
                          color: Color(0xff72591e),
                          fontSize: 11,
                          letterSpacing: .7,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(
                      data.profile.bookingEligible
                          ? 'Your provider requirements are complete and listings can accept eligible bookings.'
                          : 'Complete your provider profile and required records before your experiences can become booking eligible.',
                      style: const TextStyle(
                          color: Color(0xff5f5b4d), fontSize: 12, height: 1.5)),
                ])),
          ]),
          const SizedBox(height: 17),
          LayoutBuilder(builder: (context, constraints) {
            final tight = constraints.maxWidth < 350;
            final count = Text('$complete of $total requirements complete',
                style: const TextStyle(
                    color: Color(0xff5f5b4d),
                    fontSize: 11,
                    fontWeight: FontWeight.w700));
            const label = Text('Provider readiness',
                style: TextStyle(
                    color: Color(0xff3c4c49),
                    fontSize: 12,
                    fontWeight: FontWeight.w800));
            return tight
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [label, const SizedBox(height: 3), count])
                : Row(children: [Expanded(child: label), count]);
          }),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  color: const Color(0xff087f78))),
        ]),
      );

  Widget _dashboardStat({
    required String title,
    required String value,
    required String detail,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          key: Key(
              'provider_dashboard_summary_${title.toLowerCase().replaceAll(' ', '_')}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xffe5ebe7)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x090b3d48),
                    blurRadius: 14,
                    offset: Offset(0, 4))
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                            color: const Color(0xffe8f1ed),
                            borderRadius: BorderRadius.circular(11)),
                        child: Icon(icon,
                            color: const Color(0xff087f78), size: 19)),
                    const Spacer(),
                    const Icon(Icons.arrow_outward_rounded,
                        size: 15, color: Color(0xff91a09a)),
                  ]),
                  const SizedBox(height: 10),
                  Text(value,
                      style: const TextStyle(
                          color: Color(0xff07509a),
                          fontSize: 23,
                          fontWeight: FontWeight.w900)),
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xff17343a),
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xff61736f), fontSize: 10)),
                ]),
          ),
        ),
      );

  Widget _nextStepCard((String, String, String, IconData, VoidCallback) step) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xff073b62),
            borderRadius: BorderRadius.circular(21),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x18073b62),
                  blurRadius: 18,
                  offset: Offset(0, 7))
            ]),
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          final details =
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(step.$4, color: const Color(0xffa9ded3))),
            const SizedBox(width: 13),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('PRIORITY ACTION',
                      style: TextStyle(
                          color: Color(0xffa9ded3),
                          fontSize: 9,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(step.$1,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(step.$2,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12, height: 1.5)),
                ])),
          ]);
          final action = FilledButton.icon(
              onPressed: step.$5,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(step.$3),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff20a69a),
                  foregroundColor: Colors.white));
          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [details, const SizedBox(height: 16), action])
              : Row(children: [
                  Expanded(child: details),
                  const SizedBox(width: 18),
                  action
                ]);
        }),
      );

  Widget _journeyCard(int current) {
    const stages = [
      'PROFILE',
      'EXPERIENCE',
      'REQUIREMENTS',
      'BOOKINGS',
      'SETTLEMENT'
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xffe5ebe7))),
      child: LayoutBuilder(builder: (context, constraints) {
        final narrow = constraints.maxWidth < 690;
        final width = narrow ? 670.0 : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: width,
              child: Row(
                  children: List.generate(
                      stages.length,
                      (i) => Expanded(
                              child: Row(children: [
                            Column(children: [
                              CircleAvatar(
                                  radius: 15,
                                  backgroundColor: i <= current
                                      ? const Color(0xff087f78)
                                      : const Color(0xffedf1ef),
                                  child: Text('${i + 1}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: i <= current
                                              ? Colors.white
                                              : const Color(0xff82908b)))),
                              const SizedBox(height: 7),
                              Text(stages[i],
                                  style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: .4,
                                      fontWeight: FontWeight.w900,
                                      color: i == current
                                          ? const Color(0xff07509a)
                                          : const Color(0xff78857f))),
                              if (i == current)
                                const Text('CURRENT',
                                    style: TextStyle(
                                        fontSize: 8,
                                        color: Color(0xff087f78),
                                        fontWeight: FontWeight.w900)),
                            ]),
                            if (i < stages.length - 1)
                              Expanded(
                                  child: Container(
                                      height: 2,
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8, bottom: 26),
                                      color: i < current
                                          ? const Color(0xff087f78)
                                          : const Color(0xffe0e7e3))),
                          ]))))),
        );
      }),
    );
  }

  Widget _readinessCard(List<(String, bool, String)> requirements) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xffe5ebe7))),
        child: Column(
            children: requirements
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        Icon(
                            item.$2
                                ? Icons.check_circle_rounded
                                : item.$3 == 'PENDING' || item.$3 == 'EXPIRED'
                                    ? Icons.error_outline_rounded
                                    : Icons.radio_button_unchecked_rounded,
                            color: item.$2
                                ? const Color(0xff20815b)
                                : item.$3 == 'EXPIRED'
                                    ? const Color(0xffb5463c)
                                    : const Color(0xffb17a32),
                            size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(item.$1,
                                style: const TextStyle(
                                    color: Color(0xff17343a),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700))),
                        _readinessPill(item.$3, item.$2),
                      ]),
                    ))
                .toList()),
      );

  Widget _readinessPill(String status, bool complete) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: complete ? const Color(0xffe6f3ec) : const Color(0xfffff2df),
            borderRadius: BorderRadius.circular(20)),
        child: Text(status,
            style: TextStyle(
                color: complete
                    ? const Color(0xff26704f)
                    : const Color(0xff946529),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .25)),
      );

  Widget _bookingReadinessInfo() => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: const Color(0xffe8f1f3),
            borderRadius: BorderRadius.circular(16)),
        child:
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, color: Color(0xff087fb8)),
          SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('BOOKING READINESS',
                    style: TextStyle(
                        color: Color(0xff07509a),
                        fontSize: 10,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text(
                    'Experiences can become booking eligible when the required provider and experience checks are satisfied.',
                    style: TextStyle(
                        color: Color(0xff3e575c), fontSize: 12, height: 1.45)),
              ])),
        ]),
      );

  Widget _emptyActivity() => Container(
        key: const Key('provider_dashboard_recent_activity'),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xffe5ebe7))),
        child: const Row(children: [
          Icon(Icons.history_rounded, color: Color(0xff8a9993)),
          SizedBox(width: 10),
          Expanded(
              child: Text('No recent activity yet.',
                  style: TextStyle(color: Color(0xff61736f), fontSize: 12))),
        ]),
      );

  Widget _experiences() {
    final query = _experienceSearchController.text.trim().toLowerCase();
    final all = data.experiences;
    final eligibleCount = all.where(_isExperienceBookable).length;
    final actionRequiredCount = all.length - eligibleCount;
    final filtered = all.where((item) {
      final matchesQuery = query.isEmpty ||
          '${item.title} ${item.location}'.toLowerCase().contains(query);
      final matchesFilter = switch (_experienceFilter) {
        'Eligible' => _isExperienceBookable(item),
        'Action Required' => !_isExperienceBookable(item),
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _pageHeader(
        'Experiences',
        'Create and manage the experiences you offer on ZanziConnect.',
        FilledButton.icon(
            onPressed: _addExperience,
            icon: const Icon(Icons.add_rounded),
            label: const Text('ADD EXPERIENCE')),
      ),
      const SizedBox(height: 18),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 3 ? 2.2 : 4.2,
          children: [
            _experienceSummary(
                'Total experiences', '${all.length}', Icons.sailing_outlined),
            _experienceSummary('Booking eligible', '$eligibleCount',
                Icons.check_circle_outline),
            _experienceSummary('Action required', '$actionRequiredCount',
                Icons.fact_check_outlined),
          ],
        );
      }),
      if (!data.profile.complete) ...[
        const SizedBox(height: 14),
        _experienceNotice(
          icon: Icons.info_outline_rounded,
          title: 'PROFILE SETUP REQUIRED',
          message:
              'You can create an experience now, but booking will remain unavailable until provider requirements are complete.',
        ),
      ],
      const SizedBox(height: 20),
      if (all.isEmpty)
        _experienceEmptyState()
      else ...[
        TextField(
          controller: _experienceSearchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search your experiences...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _experienceSearchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffe1e9e5))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xffe1e9e5))),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final filter in ['All', 'Eligible', 'Action Required'])
            ChoiceChip(
              label: Text(filter),
              selected: _experienceFilter == filter,
              showCheckmark: false,
              onSelected: (_) => setState(() => _experienceFilter = filter),
              selectedColor: const Color(0xff07509a),
              backgroundColor: Colors.white,
              side: BorderSide(
                  color: _experienceFilter == filter
                      ? const Color(0xff07509a)
                      : const Color(0xffdce5e0)),
              labelStyle: TextStyle(
                  color: _experienceFilter == filter
                      ? Colors.white
                      : const Color(0xff17343a),
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
        ]),
        const SizedBox(height: 15),
        if (filtered.isEmpty)
          _emptyState('No experiences found.', 'Try another search or filter.',
              null, null)
        else
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1060
                ? 3
                : constraints.maxWidth >= 620
                    ? 2
                    : 1;
            final gap = 15.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: filtered
                  .map((item) =>
                      SizedBox(width: width, child: _experienceCard(item)))
                  .toList(),
            );
          }),
      ],
    ]);
  }

  Widget _experienceSummary(String title, String value, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xffe5ebe7))),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xffe8f1ed),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: const Color(0xff087f78), size: 19)),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(value,
                    style: const TextStyle(
                        color: Color(0xff07509a),
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                Text(title,
                    style: const TextStyle(
                        color: Color(0xff61736f),
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ])),
        ]),
      );

  Widget _experienceEmptyState() => Container(
        key: const Key('provider_experiences_empty_state'),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffe5ebe7)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0a0b3d48), blurRadius: 18, offset: Offset(0, 6))
          ],
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          final visual = Container(
            height: 178,
            width: wide ? 230 : double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffe4f1ee), Color(0xffedf4f2)])),
            child: const Stack(alignment: Alignment.center, children: [
              Positioned(
                  right: 16,
                  top: 12,
                  child: Icon(Icons.wb_sunny_outlined,
                      size: 30, color: Color(0xff7dbab1))),
              Icon(Icons.sailing_rounded, size: 70, color: Color(0xff07509a)),
              Positioned(
                  bottom: 12,
                  child: Text('ZANZIBAR · TANZANIA',
                      style: TextStyle(
                          color: Color(0xff087f78),
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w900))),
            ]),
          );
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('NO EXPERIENCES YET',
                  style: TextStyle(
                      color: Color(0xff087f78),
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text(
                  'Create your first Zanzibar experience and prepare it for booking.',
                  style: TextStyle(
                      color: Color(0xff17343a),
                      fontSize: 21,
                      height: 1.3,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 15),
              FilledButton.icon(
                  onPressed: _addExperience,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ADD YOUR FIRST EXPERIENCE')),
            ],
          );
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                wide
                    ? Row(children: [
                        visual,
                        const SizedBox(width: 24),
                        Expanded(child: intro)
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [visual, const SizedBox(height: 20), intro]),
                const SizedBox(height: 23),
                const Divider(height: 1),
                const SizedBox(height: 17),
                const Text('HOW IT WORKS',
                    style: TextStyle(
                        color: Color(0xff07509a),
                        fontSize: 10,
                        letterSpacing: .9,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _howItWorksStep('1', 'Create experience'),
                  _howItWorksStep('2', 'Add information'),
                  _howItWorksStep('3', 'Complete requirements'),
                  _howItWorksStep('4', 'Become eligible'),
                  _howItWorksStep('5', 'Receive bookings'),
                ]),
              ]);
        }),
      );

  Widget _howItWorksStep(String number, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xfff5f7f5),
            borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
              radius: 11,
              backgroundColor: const Color(0xffe2efea),
              child: Text(number,
                  style: const TextStyle(
                      color: Color(0xff087f78),
                      fontSize: 10,
                      fontWeight: FontWeight.w900))),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(
                  color: Color(0xff3e575c),
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _experienceCard(ProviderExperienceData item) {
    final eligible = _isExperienceBookable(item);
    final reason = _experienceEligibilityReason(item);
    final readyChecks = _experienceReadinessCount();
    return Container(
      key: Key('provider_experience_card_${item.id}'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffe4ebe7)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0c0b3d48), blurRadius: 18, offset: Offset(0, 5))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          height: 130,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff0b5072), Color(0xff0b898d)])),
          child: Stack(children: [
            const Positioned(
                right: -8,
                bottom: -28,
                child: Icon(Icons.waves_rounded,
                    size: 138, color: Color(0x337fffff))),
            Center(
                child: Icon(
                    item.category.toLowerCase().contains('dhow')
                        ? Icons.sailing_rounded
                        : Icons.water_rounded,
                    color: Colors.white,
                    size: 58)),
            Positioned(
                top: 12,
                left: 13,
                child: _experienceBadge(
                    item.active ? 'ACTIVE' : 'INACTIVE',
                    item.active
                        ? _ExperienceBadgeStyle.neutral
                        : _ExperienceBadgeStyle.warning)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xff17343a),
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text('${item.category} · ${item.location}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xff61736f),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(spacing: 14, runSpacing: 8, children: [
              _experienceFact(
                  Icons.payments_outlined, 'TZS ${_formatMoney(item.price)}'),
              _experienceFact(
                  Icons.group_outlined, 'Capacity ${item.capacity} guests'),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 7, runSpacing: 7, children: [
              _experienceBadge(
                  eligible ? 'BOOKING ELIGIBLE' : 'ACTION REQUIRED',
                  eligible
                      ? _ExperienceBadgeStyle.success
                      : _ExperienceBadgeStyle.warning),
            ]),
            const SizedBox(height: 9),
            Text(
                eligible
                    ? 'Visitors can currently book this experience.'
                    : reason,
                style: TextStyle(
                    color: eligible
                        ? const Color(0xff39745c)
                        : const Color(0xff8a5729),
                    fontSize: 11,
                    height: 1.4)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.fact_check_outlined,
                  size: 15, color: Color(0xff087f78)),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(
                      'Booking readiness · $readyChecks of 5 checks complete',
                      style: const TextStyle(
                          color: Color(0xff526661),
                          fontSize: 10,
                          fontWeight: FontWeight.w700))),
              TextButton(
                  onPressed: () => _showRequirements(item),
                  child: const Text('MANAGE REQUIREMENTS',
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.w900))),
            ]),
            ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                    value: readyChecks / 5,
                    minHeight: 5,
                    backgroundColor: const Color(0xffe9efec),
                    color: const Color(0xff087f78))),
            const SizedBox(height: 10),
            Wrap(spacing: 3, runSpacing: 2, children: [
              TextButton.icon(
                  onPressed: () => _showExperience(item),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('VIEW')),
              TextButton.icon(
                  onPressed: () => _editExperience(item),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('EDIT')),
              TextButton.icon(
                  onPressed: () => setState(() => item.active = !item.active),
                  icon: Icon(
                      item.active
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 16),
                  label: Text(item.active ? 'SET INACTIVE' : 'SET ACTIVE')),
            ]),
          ]),
        ),
      ]),
    );
  }

  bool _isExperienceBookable(ProviderExperienceData item) =>
      item.active && data.profile.bookingEligible;

  String _experienceEligibilityReason(ProviderExperienceData item) {
    if (!item.active) return 'Set this experience active to allow bookings.';
    return data.profile.unavailableReason;
  }

  int _experienceReadinessCount() {
    final p = data.profile;
    return [
      p.active,
      p.complete && p.recordValid,
      p.documentsValid && p.documentExpiry != null && !p.documentExpired,
      p.capacity > 0,
      p.departureChecksComplete,
    ].where((complete) => complete).length;
  }

  void _showRequirements(ProviderExperienceData item) {
    final p = data.profile;
    final checks = [
      (
        'Provider active',
        p.active,
        p.active ? 'Active' : 'Provider status is inactive.'
      ),
      (
        'Provider record',
        p.complete && p.recordValid,
        !p.complete
            ? 'Complete your provider profile.'
            : p.recordValid
                ? 'Record valid'
                : 'Required provider record is incomplete.'
      ),
      (
        'Required documents',
        p.documentsValid && p.documentExpiry != null && !p.documentExpired,
        p.documentStatus == 'EXPIRED'
            ? 'Required provider document has expired.'
            : p.documentsValid
                ? p.documentStatus
                : 'Required provider documents are incomplete.'
      ),
      (
        'Capacity configured',
        p.capacity > 0,
        p.capacity > 0
            ? '${p.capacity} guests available'
            : 'No capacity is currently available.'
      ),
      (
        'Departure checks',
        p.departureChecksComplete,
        p.departureChecksComplete
            ? 'Checks complete'
            : 'Required departure checks are incomplete.'
      ),
    ];
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Booking Requirements'),
        content: SizedBox(
          width: 460,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(item.title,
                    style: const TextStyle(
                        color: Color(0xff61736f),
                        fontSize: 12,
                        fontWeight: FontWeight.w700))),
            const SizedBox(height: 8),
            ...checks.map((check) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(children: [
                    Icon(check.$2 ? Icons.check_circle : Icons.error_outline,
                        color: check.$2
                            ? const Color(0xff20815b)
                            : const Color(0xffb17a32),
                        size: 18),
                    const SizedBox(width: 9),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(check.$1,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w800)),
                          Text(check.$3,
                              style: const TextStyle(
                                  color: Color(0xff61736f),
                                  fontSize: 10,
                                  height: 1.4)),
                        ])),
                  ]),
                )),
            const SizedBox(height: 6),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'This experience is ${_isExperienceBookable(item) ? 'booking eligible' : 'not currently bookable'}.',
                    style: const TextStyle(
                        color: Color(0xff07509a),
                        fontSize: 11,
                        fontWeight: FontWeight.w800))),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CLOSE')),
          if (!_isExperienceBookable(item))
            FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  setState(() => _index = 4);
                },
                child: const Text('MANAGE PROFILE')),
        ],
      ),
    );
  }

  Widget _experienceNotice({
    required IconData icon,
    required String title,
    required String message,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xfffff3df),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xfff0dfbd))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: const Color(0xff9a6d27)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xff795c28),
                        fontSize: 10,
                        letterSpacing: .5,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(message,
                    style: const TextStyle(
                        color: Color(0xff665b44), fontSize: 11, height: 1.45)),
              ])),
        ]),
      );

  Widget _experienceBadge(String label, _ExperienceBadgeStyle style) {
    final (foreground, background) = switch (style) {
      _ExperienceBadgeStyle.success => (
          const Color(0xff206b4e),
          const Color(0xffe5f3eb)
        ),
      _ExperienceBadgeStyle.warning => (
          const Color(0xff895c21),
          const Color(0xfffff1dc)
        ),
      _ExperienceBadgeStyle.neutral => (const Color(0xff07509a), Colors.white),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: foreground,
              fontSize: 9,
              letterSpacing: .35,
              fontWeight: FontWeight.w900)),
    );
  }

  Widget _experienceFact(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xff087f78), size: 15),
        const SizedBox(width: 5),
        Text(text,
            style: const TextStyle(
                color: Color(0xff526661),
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      ]);

  String _formatMoney(int amount) => amount
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  Widget _bookings() {
    const total = 0;
    const upcoming = 0;
    const completed = 0;
    final query = _bookingSearchController.text.trim();
    final emptyTitle = query.isNotEmpty
        ? 'No bookings found'
        : _bookingFilter == 'All'
            ? 'NO BOOKINGS YET'
            : 'No ${_bookingFilter.toLowerCase()} bookings';
    final emptyDescription = query.isNotEmpty
        ? 'No provider booking records are available to match "$query".'
        : _bookingFilter == 'All'
            ? 'When visitors book your eligible experiences, their bookings will appear here.'
            : 'There are no ${_bookingFilter.toLowerCase()} bookings for this provider yet.';

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _pageHeader('Bookings',
          'Manage bookings for your ZanziConnect experiences.', null),
      const SizedBox(height: 18),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 3 ? 2.35 : 4.4,
          children: [
            _bookingSummaryCard(
                'Upcoming', '$upcoming', Icons.event_available_outlined),
            _bookingSummaryCard(
                'Completed', '$completed', Icons.task_alt_outlined),
            _bookingSummaryCard(
                'Total bookings', '$total', Icons.book_outlined),
          ],
        );
      }),
      const SizedBox(height: 17),
      TextField(
        controller: _bookingSearchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search bookings...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _bookingSearchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xffe1e9e5))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xffe1e9e5))),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final filter in ['All', 'Upcoming', 'Completed'])
          ChoiceChip(
            key: Key('provider_bookings_filter_${filter.toLowerCase()}'),
            label: Text(filter),
            selected: _bookingFilter == filter,
            showCheckmark: false,
            onSelected: (_) => setState(() => _bookingFilter = filter),
            selectedColor: const Color(0xff07509a),
            backgroundColor: Colors.white,
            side: BorderSide(
                color: _bookingFilter == filter
                    ? const Color(0xff07509a)
                    : const Color(0xffdce5e0)),
            labelStyle: TextStyle(
                color: _bookingFilter == filter
                    ? Colors.white
                    : const Color(0xff17343a),
                fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
      ]),
      const SizedBox(height: 18),
      _bookingEmptyState(emptyTitle, emptyDescription),
      const SizedBox(height: 12),
      _bookingDataNotice(),
    ]);
  }

  Widget _bookingSummaryCard(String label, String value, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xffe5ebe7))),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xffe8f1ed),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: const Color(0xff087f78), size: 19)),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(value,
                    style: const TextStyle(
                        color: Color(0xff07509a),
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        color: Color(0xff61736f),
                        fontSize: 9,
                        letterSpacing: .4,
                        fontWeight: FontWeight.w800)),
              ])),
        ]),
      );

  Widget _bookingEmptyState(String title, String description) => Container(
        key: const Key('provider_bookings_empty_state'),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffe5ebe7)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0a0b3d48), blurRadius: 18, offset: Offset(0, 6))
          ],
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 690;
          final visual = Container(
            height: 156,
            width: wide ? 195 : double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xffe5f1ef), Color(0xffedf4f2)])),
            child: const Stack(alignment: Alignment.center, children: [
              Positioned(
                  right: 14,
                  top: 12,
                  child: Icon(Icons.waves_rounded,
                      size: 42, color: Color(0xff9ac9c0))),
              Icon(Icons.calendar_month_rounded,
                  size: 54, color: Color(0xff07509a)),
            ]),
          );
          final message =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Color(0xff087f78),
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(description,
                style: const TextStyle(
                    color: Color(0xff17343a),
                    fontSize: 17,
                    height: 1.45,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            FilledButton.icon(
                onPressed: () => _openTab(1),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('VIEW MY EXPERIENCES')),
          ]);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                wide
                    ? Row(children: [
                        visual,
                        const SizedBox(width: 22),
                        Expanded(child: message)
                      ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            visual,
                            const SizedBox(height: 18),
                            message
                          ]),
                const SizedBox(height: 21),
                const Divider(height: 1),
                const SizedBox(height: 15),
                const Text('BOOKING JOURNEY',
                    style: TextStyle(
                        color: Color(0xff07509a),
                        fontSize: 9,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 9),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _bookingJourneyStep('Eligible experience'),
                  _bookingJourneyStep('Visitor booking'),
                  _bookingJourneyStep('Provider management'),
                  _bookingJourneyStep('Completion'),
                  _bookingJourneyStep('Settlement'),
                ]),
              ]);
        }),
      );

  Widget _bookingJourneyStep(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xfff5f7f5),
            borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 14, color: Color(0xff087f78)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Color(0xff3e575c),
                  fontSize: 9,
                  fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _bookingDataNotice() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xffe8f1f3),
            borderRadius: BorderRadius.circular(15)),
        child:
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, color: Color(0xff087fb8), size: 19),
          SizedBox(width: 9),
          Expanded(
              child: Text(
                  'Provider bookings are not yet connected to registered provider accounts in this prototype. No bookings are shown until linked records are available.',
                  style: TextStyle(
                      color: Color(0xff3e575c), fontSize: 11, height: 1.45))),
        ]),
      );

  Widget _settlements() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
              'Settlements',
              'Track settlement status for your completed ZanziConnect experiences.',
              null),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xffe5f3f1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xff087f78)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NO SETTLEMENTS YET',
                                style: TextStyle(
                                    color: Color(0xff17343a),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(height: 4),
                            Text(
                                'Settlement records will appear here after eligible bookings are completed.',
                                style: TextStyle(
                                    color: Color(0xff61736f), height: 1.45)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f7f5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Text(
                      'Provider bookings and settlement records are not connected to this account yet. No transaction amounts or statuses are available to show.',
                      style: TextStyle(
                          color: Color(0xff3e575c), fontSize: 12, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (index, label) in [
                        'Booking',
                        'Complete experience',
                        'Settlement eligibility',
                        'Settlement record',
                      ].indexed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 9),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffe0e8e5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}. $label',
                            style: const TextStyle(
                                color: Color(0xff3e575c),
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    key: const Key('provider_settlements_view_bookings'),
                    onPressed: () => _openTab(2),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('VIEW BOOKINGS →'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _profile() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
              'Provider Profile',
              'Your account and provider requirements.',
              OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('EDIT PROFILE'))),
          const SizedBox(height: 16),
          _infoCard('ACCOUNT INFORMATION', [
            _pair('Provider name', widget.account.fullName),
            _pair('Email', widget.account.email),
            _pair('Phone', widget.account.phone),
            _pair('Role', 'PROVIDER'),
          ]),
          const SizedBox(height: 12),
          _infoCard('PROVIDER INFORMATION', [
            _pair(
                'Business / provider name',
                data.profile.businessName.isEmpty
                    ? 'Not provided'
                    : data.profile.businessName),
            _pair(
                'Description',
                data.profile.description.isEmpty
                    ? 'Not provided'
                    : data.profile.description),
            _pair(
                'Location',
                data.profile.location.isEmpty
                    ? 'Not provided'
                    : data.profile.location),
            _pair('Provider status',
                data.profile.active ? 'ACTIVE' : data.profile.status),
            _pair(
                'Document expiry',
                data.profile.documentExpiry
                        ?.toIso8601String()
                        .split('T')
                        .first ??
                    'Not provided'),
          ]),
          const SizedBox(height: 12),
          _requirements(),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('LOG OUT'),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Profile information is local prototype data.',
              style: TextStyle(color: Color(0xff61736f), fontSize: 12)),
        ],
      );

  Widget _requirements() {
    final p = data.profile;
    return _infoCard('REQUIRED RECORDS & CHECKS', [
      _pair('Provider active status', _state(p.active)),
      _pair('Provider record status', _state(p.recordValid)),
      _pair('Required documents', p.documentStatus),
      _pair('Capacity status',
          p.capacity > 0 ? 'VALID · ${p.capacity} guests' : 'INCOMPLETE'),
      _pair('Departure checks', _state(p.departureChecksComplete)),
    ]);
  }

  String _state(bool value) => value ? 'VALID' : 'INCOMPLETE';

  Widget _pageHeader(String title, String subtitle, Widget? action) =>
      LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        final heading =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xff07509a),
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(color: Color(0xff61736f))),
        ]);
        if (compact) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading,
                if (action != null) ...[const SizedBox(height: 12), action],
              ]);
        }
        return Row(children: [
          Expanded(child: heading),
          if (action != null) action,
        ]);
      });

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xff07509a), fontSize: 16, fontWeight: FontWeight.w900));

  Widget _infoCard(String title, List<Widget> children) => Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionTitle(title),
            const SizedBox(height: 8),
            ...children,
          ]),
        ),
      );

  Widget _pair(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 190,
              child: Text(label,
                  style: const TextStyle(color: Color(0xff61736f)))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
        ]),
      );

  Widget _emptyState(
          String title, String detail, String? button, VoidCallback? action) =>
      Card(
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(children: [
              const Icon(Icons.inbox_outlined,
                  color: Color(0xff087fb8), size: 38),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(detail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xff61736f))),
              if (button != null && action != null) ...[
                const SizedBox(height: 14),
                FilledButton(onPressed: action, child: Text(button)),
              ],
            ]),
          ),
        ),
      );

  void _addExperience() => _experienceForm();
  void _editExperience(ProviderExperienceData item) =>
      _experienceForm(item: item);

  Future<void> _experienceForm({ProviderExperienceData? item}) async {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController(text: item?.title ?? '');
    final description = TextEditingController(text: item?.description ?? '');
    final location =
        TextEditingController(text: item?.location ?? data.profile.location);
    final price =
        TextEditingController(text: item == null ? '' : '${item.price}');
    final capacity =
        TextEditingController(text: item == null ? '2' : '${item.capacity}');
    final includes = TextEditingController(text: item?.includes ?? '');
    final cancellation = TextEditingController(
        text: item?.cancellationPolicy ?? 'Free until 24 hours before');
    var category = item?.category ?? 'Marine';
    final categories = [
      'Marine',
      'Dhow',
      'Culture',
      'Tours',
      'Food',
      'Wellness'
    ];
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
                title:
                    Text(item == null ? 'Add Experience' : 'Edit Experience'),
                content: SizedBox(
                  width: 520,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        _formField(title, 'Experience Title'),
                        _formField(description, 'Description', maxLines: 3),
                        _formField(location, 'Location'),
                        _formField(price, 'Price (TZS)', numeric: true),
                        _formField(capacity, 'Default Guests / Capacity',
                            numeric: true),
                        _formField(includes, "What's Included"),
                        _formField(cancellation, 'Cancellation Policy'),
                        DropdownButtonFormField<String>(
                          initialValue: category,
                          decoration: const InputDecoration(
                              labelText: 'Experience Category'),
                          items: categories
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text(value)))
                              .toList(),
                          onChanged: (value) => setDialogState(
                              () => category = value ?? category),
                        ),
                      ]),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('CANCEL')),
                  FilledButton(
                      onPressed: () {
                        if (formKey.currentState!.validate())
                          Navigator.pop(dialogContext, true);
                      },
                      child: const Text('SAVE EXPERIENCE')),
                ],
              )),
    );
    if (saved == true && mounted) {
      setState(() {
        if (item == null) {
          data.experiences.add(ProviderExperienceData(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title.text.trim(),
            description: description.text.trim(),
            location: location.text.trim(),
            price: int.parse(price.text),
            capacity: int.parse(capacity.text),
            includes: includes.text.trim(),
            cancellationPolicy: cancellation.text.trim(),
            category: category,
          ));
        } else {
          item.title = title.text.trim();
          item.description = description.text.trim();
          item.location = location.text.trim();
          item.price = int.parse(price.text);
          item.capacity = int.parse(capacity.text);
          item.includes = includes.text.trim();
          item.cancellationPolicy = cancellation.text.trim();
          item.category = category;
        }
        _index = 1;
      });
    }
    // The dialog route is still animating out when showDialog completes.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final controller in [
      title,
      description,
      location,
      price,
      capacity,
      includes,
      cancellation
    ]) {
      controller.dispose();
    }
  }

  Widget _formField(TextEditingController controller, String label,
          {int maxLines = 1, bool numeric = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          key: Key('provider_field_$label'),
          controller: controller,
          maxLines: maxLines,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required.';
            if (numeric && (int.tryParse(value.trim()) ?? 0) <= 0)
              return 'Enter a number greater than zero.';
            return null;
          },
        ),
      );

  void _showExperience(ProviderExperienceData item) {
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(item.title),
              content: Text(
                  '${item.description}\n\nLocation: ${item.location}\nPrice: TZS ${item.price}\nCapacity: ${item.capacity}\nIncluded: ${item.includes}\nCancellation: ${item.cancellationPolicy}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CLOSE'))
              ],
            ));
  }

  Future<void> _editProfile() async {
    final formKey = GlobalKey<FormState>();
    final profile = data.profile;
    final name = TextEditingController(text: profile.businessName);
    final description = TextEditingController(text: profile.description);
    final location = TextEditingController(text: profile.location);
    final expiry = TextEditingController(
        text: profile.documentExpiry?.toIso8601String().split('T').first ?? '');
    final capacity = TextEditingController(
        text: profile.capacity == 0 ? '' : '${profile.capacity}');
    var active = profile.active,
        record = profile.recordValid,
        documents = profile.documentsValid,
        departure = profile.departureChecksComplete;
    final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title: const Text('Provider Profile'),
                  content: SizedBox(
                      width: 520,
                      child: SingleChildScrollView(
                          child: Form(
                              key: formKey,
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _formField(
                                        name, 'Business / Provider Name'),
                                    _formField(description, 'Description',
                                        maxLines: 3),
                                    _formField(location, 'Location'),
                                    _formField(capacity, 'Available Capacity',
                                        numeric: true),
                                    _formField(
                                        expiry, 'Document Expiry (YYYY-MM-DD)'),
                                    SwitchListTile(
                                        title: const Text('Provider active'),
                                        value: active,
                                        onChanged: (v) =>
                                            setDialogState(() => active = v)),
                                    SwitchListTile(
                                        title:
                                            const Text('Provider record valid'),
                                        value: record,
                                        onChanged: (v) =>
                                            setDialogState(() => record = v)),
                                    SwitchListTile(
                                        title: const Text(
                                            'Required documents valid'),
                                        value: documents,
                                        onChanged: (v) => setDialogState(
                                            () => documents = v)),
                                    SwitchListTile(
                                        title: const Text(
                                            'Departure checks complete'),
                                        value: departure,
                                        onChanged: (v) => setDialogState(
                                            () => departure = v)),
                                    const Text(
                                        'These are prototype status fields. ZanziConnect does not issue government certification.',
                                        style: TextStyle(fontSize: 12)),
                                  ])))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('CANCEL')),
                    FilledButton(
                        onPressed: () {
                          final parsedDate =
                              DateTime.tryParse(expiry.text.trim());
                          if (formKey.currentState!.validate() &&
                              (expiry.text.isEmpty || parsedDate != null))
                            Navigator.pop(dialogContext, true);
                        },
                        child: const Text('SAVE PROFILE')),
                  ],
                )));
    if (saved == true && mounted) {
      setState(() {
        profile.businessName = name.text.trim();
        profile.description = description.text.trim();
        profile.location = location.text.trim();
        profile.capacity = int.parse(capacity.text);
        profile.documentExpiry = DateTime.tryParse(expiry.text.trim());
        profile.active = active;
        profile.recordValid = record;
        profile.documentsValid = documents;
        profile.departureChecksComplete = departure;
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (final controller in [name, description, location, expiry, capacity]) {
      controller.dispose();
    }
  }
}

class _PrototypeTag extends StatelessWidget {
  const _PrototypeTag();

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xffe6f2f5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('LOCAL PROTOTYPE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
      );
}

enum _ExperienceBadgeStyle { success, warning, neutral }
