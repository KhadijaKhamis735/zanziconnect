import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/registered_account.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final ValueChanged<RegisteredAccount> onAuthenticated;

  const WelcomeScreen({
    required this.onAuthenticated,
    super.key,
  });

  static const _ocean = Color(0xff07509a);
  static const _teal = Color(0xff087fb8);
  static const _ink = Color(0xff14313d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff073b62), Color(0xff087d91), Color(0xfff5f2ea)],
            stops: [0, .58, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final content = desktop
                ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(child: _intro(context, true)),
                    const SizedBox(width: 56),
                    Expanded(child: _passportPreview()),
                  ])
                : Column(children: [
                    _intro(context, false),
                    const SizedBox(height: 30),
                    _passportPreview(),
                  ]);
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: desktop ? 8 : 22,
                vertical: desktop ? 24 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: desktop ? constraints.maxHeight - 48 : 0,
                    ),
                    child: content,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _intro(BuildContext context, bool desktop) => Column(
        crossAxisAlignment:
            desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          _brandHeader(desktop),
          SizedBox(height: desktop ? 66 : 30),
          Text('Discover • Book • Experience Zanzibar',
              textAlign: desktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: desktop ? 42 : 30,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1)),
          const SizedBox(height: 17),
          Text(
              "A clearer transaction journey for Zanzibar's tourism and coastal experiences.",
              textAlign: desktop ? TextAlign.left : TextAlign.center,
              style: const TextStyle(
                  color: Color(0xffe0f2ee), fontSize: 17, height: 1.6)),
          const SizedBox(height: 24),
          const Text('ONE JOURNEY. ONE CONNECTED RECORD.',
              style: TextStyle(
                  color: Color(0xffffd99a),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7)),
          const SizedBox(height: 13),
          Wrap(
            alignment: desktop ? WrapAlignment.start : WrapAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: const [
              Text('DISCOVER → CHECK → BOOK',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .25)),
              Text('EXPERIENCE → RECORD → SETTLE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .25)),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
              width: desktop ? 250 : double.infinity,
              child: FilledButton(
                onPressed: () => _openLogin(context),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffffc76a),
                    foregroundColor: const Color(0xff12384d),
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17))),
                child: const Text('GET STARTED',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 1.1)),
              )),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                  onPressed: () => _openLogin(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('LOG IN')),
              const Text('·', style: TextStyle(color: Colors.white70)),
              TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => CreateAccountScreen(
                              onAuthenticated: onAuthenticated))),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('NEW TO ZANZICONNECT?  CREATE ACCOUNT')),
            ],
          ),
          const SizedBox(height: 8),
          const Text('ZANZIBAR · TANZANIA',
              style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2)),
        ],
      );

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => LoginScreen(onAuthenticated: onAuthenticated),
    ));
  }

  Widget _passportPreview() => Container(
        constraints: const BoxConstraints(maxWidth: 510),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
            color: const Color(0xfffbfaf6),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .19),
                  blurRadius: 38,
                  offset: const Offset(0, 18))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: const Color(0xffe3f1ed),
                    borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.badge_outlined, color: _teal)),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('TRIP PASSPORT',
                      style: TextStyle(
                          color: _ocean,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5)),
                  Text('Your journey, connected',
                      style: TextStyle(color: Color(0xff667976), fontSize: 12)),
                ])),
            const Icon(Icons.more_horiz, color: Color(0xff8a9994)),
          ]),
          const SizedBox(height: 22),
          Container(
              height: 112,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  gradient: const LinearGradient(
                      colors: [Color(0xff0a597b), Color(0xff42a9ad)])),
              child: Stack(children: [
                Positioned(
                    right: 14,
                    top: 12,
                    child: Icon(Icons.wb_sunny_rounded,
                        color: Colors.white.withValues(alpha: .65), size: 32)),
                const Positioned(
                    left: 18,
                    bottom: 16,
                    child: Text('ZANZIBAR  /  COASTAL EXPERIENCE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w800))),
                const Positioned(
                    right: 26,
                    bottom: 6,
                    child: Icon(Icons.sailing_rounded,
                        size: 62, color: Color(0xffe7f3e9))),
              ])),
          const SizedBox(height: 20),
          const Text('DEMO / ILLUSTRATIVE',
              style: TextStyle(
                  color: Color(0xff89958f),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4)),
          const SizedBox(height: 8),
          const Text('ZC-2026-00001',
              style: TextStyle(
                  color: _ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('Sunset Dhow Cruise',
              style: TextStyle(
                  color: _ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4)),
          const SizedBox(height: 4),
          const Row(children: [
            Icon(Icons.location_on_outlined, size: 15, color: _teal),
            SizedBox(width: 4),
            Text('Nungwi · Zanzibar',
                style: TextStyle(color: Color(0xff71817c), fontSize: 13))
          ]),
          const SizedBox(height: 18),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xffe7f4ee),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('BOOKING ELIGIBLE',
                  style: TextStyle(
                      color: Color(0xff207653),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7))),
          const SizedBox(height: 15),
          const Text(
              '✓  Provider check     ✓  Required records     ✓  Capacity',
              style: TextStyle(
                  color: Color(0xff596c67), fontSize: 11, height: 1.5)),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 15),
          const Wrap(spacing: 12, runSpacing: 8, children: [
            _JourneyStep('CHECK', true),
            _JourneyStep('BOOK', false),
            _JourneyStep('EXPERIENCE', false),
            _JourneyStep('SETTLE', false),
          ]),
          const SizedBox(height: 13),
          const Text('Your journey, connected from booking to settlement.',
              style: TextStyle(
                  color: Color(0xff71817c), fontSize: 12, height: 1.4)),
        ]),
      );

  Widget _brandHeader(bool desktop) {
    return Row(
      mainAxisAlignment:
          desktop ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        const CoastalLogoMark(size: 48),
        const SizedBox(width: 11),
        const Text(
          'ZanziConnect',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: -.6,
          ),
        ),
      ],
    );
  }
}

class _JourneyStep extends StatelessWidget {
  final String label;
  final bool complete;

  const _JourneyStep(this.label, this.complete);

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(complete ? Icons.check_circle : Icons.circle_outlined,
            size: 15,
            color: complete ? _WelcomeColors.teal : const Color(0xffb6c1bc)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
                color: _WelcomeColors.ink)),
      ]);
}

class _WelcomeColors {
  static const teal = Color(0xff087fb8);
  static const ink = Color(0xff14313d);
}

/// Flutter-native interpretation of the supplied coastal logo, with the
/// original bottom wording replaced by ZanziConnect.
class CoastalLogoMark extends StatelessWidget {
  final double size;

  const CoastalLogoMark({required this.size, super.key});

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _CoastalLogoPainter()),
      );
}

class _CoastalLogoPainter extends CustomPainter {
  static const _navy = Color(0xff064a95);
  static const _blue = Color(0xff137fbd);
  static const _sky = Color(0xffbce8f5);
  static const _green = Color(0xff11884c);
  static const _gold = Color(0xffffbf2f);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    canvas.save();
    canvas.scale(scale);

    canvas.drawCircle(
      const Offset(100, 100),
      98,
      Paint()..color = _navy,
    );
    canvas.drawCircle(
      const Offset(100, 100),
      92,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(100, 100),
      86,
      Paint()..color = _sky,
    );

    // Sun and rays.
    final sunPaint = Paint()
      ..color = _gold
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final start =
          Offset(132 + 20 * math.cos(angle), 48 + 20 * math.sin(angle));
      final end = Offset(132 + 27 * math.cos(angle), 48 + 27 * math.sin(angle));
      canvas.drawLine(start, end, sunPaint);
    }
    canvas.drawCircle(const Offset(132, 48), 13, Paint()..color = _gold);

    // Palm trunk and broad green fronds.
    final trunk = Paint()
      ..color = const Color(0xff80522b)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final trunkPath = Path()
      ..moveTo(58, 139)
      ..quadraticBezierTo(67, 100, 78, 70);
    canvas.drawPath(trunkPath, trunk);
    final frondPaint = Paint()
      ..color = _green
      ..style = PaintingStyle.fill;
    final fronds = [
      Path()
        ..moveTo(78, 73)
        ..quadraticBezierTo(58, 45, 30, 50)
        ..quadraticBezierTo(46, 67, 75, 78)
        ..close(),
      Path()
        ..moveTo(78, 73)
        ..quadraticBezierTo(64, 35, 48, 29)
        ..quadraticBezierTo(56, 57, 77, 80)
        ..close(),
      Path()
        ..moveTo(78, 73)
        ..quadraticBezierTo(81, 35, 104, 27)
        ..quadraticBezierTo(96, 57, 81, 81)
        ..close(),
      Path()
        ..moveTo(78, 73)
        ..quadraticBezierTo(111, 42, 135, 48)
        ..quadraticBezierTo(111, 67, 81, 80)
        ..close(),
      Path()
        ..moveTo(78, 73)
        ..quadraticBezierTo(118, 67, 129, 86)
        ..quadraticBezierTo(102, 88, 79, 80)
        ..close(),
    ];
    for (final frond in fronds) {
      canvas.drawPath(frond, frondPaint);
    }

    // Dhow sails and hull.
    final mast = Paint()
      ..color = _navy
      ..strokeWidth = 2.5;
    canvas.drawLine(const Offset(143, 76), const Offset(143, 131), mast);
    final sailPaint = Paint()..color = _navy;
    final leftSail = Path()
      ..moveTo(140, 81)
      ..lineTo(118, 119)
      ..lineTo(140, 119)
      ..close();
    final rightSail = Path()
      ..moveTo(146, 88)
      ..lineTo(167, 120)
      ..lineTo(146, 120)
      ..close();
    canvas.drawPath(leftSail, sailPaint);
    canvas.drawPath(rightSail, sailPaint);

    final sea = Path()
      ..moveTo(15, 128)
      ..quadraticBezierTo(47, 113, 77, 127)
      ..quadraticBezierTo(111, 141, 143, 125)
      ..quadraticBezierTo(166, 114, 185, 126)
      ..lineTo(185, 179)
      ..lineTo(15, 179)
      ..close();
    canvas.drawPath(sea, Paint()..color = _navy);
    canvas.drawPath(
      Path()
        ..moveTo(17, 137)
        ..quadraticBezierTo(48, 124, 78, 138)
        ..quadraticBezierTo(110, 151, 143, 136)
        ..quadraticBezierTo(164, 127, 183, 138),
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawPath(
      Path()
        ..moveTo(18, 151)
        ..quadraticBezierTo(49, 139, 80, 151)
        ..quadraticBezierTo(112, 164, 145, 150)
        ..quadraticBezierTo(166, 141, 182, 150),
      Paint()
        ..color = const Color(0xff4bb7df)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final label = TextPainter(
      text: const TextSpan(
        text: 'ZANZICONNECT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 150);
    label.paint(canvas, Offset(100 - label.width / 2, 162));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
