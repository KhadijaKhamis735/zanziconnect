import 'package:flutter/material.dart';

import '../models/registered_account.dart';

class ProviderDashboard extends StatelessWidget {
  final RegisteredAccount account;
  final int upcomingBookings;
  final int completedBookings;
  final bool hasBooking;
  final String settlementState;
  final String experienceState;
  final String complaintState;
  final ValueChanged<BuildContext> onCompleteExperience;
  final ValueChanged<BuildContext> onProcessSettlement;
  final VoidCallback onLogout;

  const ProviderDashboard({
    required this.account,
    required this.upcomingBookings,
    required this.completedBookings,
    required this.hasBooking,
    required this.settlementState,
    required this.experienceState,
    required this.complaintState,
    required this.onCompleteExperience,
    required this.onProcessSettlement,
    required this.onLogout,
    super.key,
  });

  static const _ocean = Color(0xff07509a);
  static const _teal = Color(0xff087fb8);
  static const _sand = Color(0xfff5f2ea);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sand,
      appBar: AppBar(
        backgroundColor: _sand,
        foregroundColor: _ocean,
        title: const Text('Provider dashboard'),
        actions: [
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('LOG OUT'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ZanziConnect Provider',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _ocean,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Welcome, ${account.fullName}',
                    style: const TextStyle(
                      color: Color(0xff61736f),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ACCOUNT',
                            style: TextStyle(
                              color: _teal,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(account.fullName,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w800)),
                          Text(account.email),
                          Text('Role: ${account.role.apiValue}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _statusCard(
                    'Provider status',
                    'PROFILE SETUP REQUIRED',
                    Icons.storefront_outlined,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'QUICK OVERVIEW · DEMO DATA',
                    style: TextStyle(
                      color: _ocean,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _metric('Experiences', '0'),
                      _metric('Upcoming bookings', '$upcomingBookings'),
                      _metric('Completed bookings', '$completedBookings'),
                      _metric('Pending settlement', settlementState),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sunset Dhow Cruise',
                            style: TextStyle(
                              color: _ocean,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text('DEMO DATA · Nungwi Blue Dhow'),
                          const SizedBox(height: 9),
                          if (hasBooking) ...[
                            Text('Experience: $experienceState'),
                            Text('Complaint: $complaintState'),
                            Text('Settlement: $settlementState'),
                          ] else
                            const Text(
                              'No bookings are linked to this demo provider account.',
                            ),
                          const SizedBox(height: 13),
                          if (hasBooking && experienceState == 'UPCOMING')
                            FilledButton.icon(
                              onPressed: () => onCompleteExperience(context),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('MARK EXPERIENCE COMPLETED'),
                            ),
                          if (hasBooking &&
                              experienceState == 'COMPLETED' &&
                              settlementState == 'ELIGIBLE')
                            FilledButton.icon(
                              onPressed: () => onProcessSettlement(context),
                              icon: const Icon(Icons.payments_outlined),
                              label: const Text('PROCESS DEMO SETTLEMENT'),
                            ),
                          if (complaintState == 'OPEN')
                            const Text(
                              'Settlement is on hold while this demo complaint is open.',
                              style: TextStyle(color: Color(0xff9a572a)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Illustrative prototype data. Final provider checks and settlement terms are determined during the pilot.',
                    style: TextStyle(
                      color: Color(0xff71817c),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(String label, String value, IconData icon) => Card(
        color: const Color(0xffe6f2f5),
        child: ListTile(
          leading: Icon(icon, color: _teal),
          title: Text(label),
          subtitle: Text(value,
              style:
                  const TextStyle(color: _teal, fontWeight: FontWeight.w900)),
        ),
      );

  Widget _metric(String label, String value) => SizedBox(
        width: 172,
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xff61736f), fontSize: 12)),
                const SizedBox(height: 5),
                Text(value,
                    style: const TextStyle(
                        color: _ocean,
                        fontSize: 19,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      );
}

class AdminDashboard extends StatelessWidget {
  final RegisteredAccount account;
  final VoidCallback onLogout;

  const AdminDashboard({
    required this.account,
    required this.onLogout,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xfff5f2ea),
        appBar: AppBar(
          title: const Text('Admin dashboard'),
          actions: [
            TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('LOG OUT'),
            ),
          ],
        ),
        body: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ZanziConnect Admin',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Text('Welcome, ${account.fullName}'),
                  Text('Account: ${account.role.apiValue}'),
                  const SizedBox(height: 12),
                  const Text(
                    'Administrative tools will be added in a later step.',
                    style: TextStyle(color: Color(0xff61736f)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
