import 'package:flutter/material.dart';

import '../models/registered_account.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  final ValueChanged<RegisteredAccount> onAuthenticated;

  const LoginScreen({
    required this.onAuthenticated,
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _ocean = Color(0xff07509a);
  static const _teal = Color(0xff087fb8);
  static const _sand = Color(0xfff5f2ea);
  static const _ink = Color(0xff14313d);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sand,
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
            final body = desktop
                ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(child: _brandPanel()),
                    const SizedBox(width: 64),
                    Expanded(child: Center(child: _loginCard())),
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        _mobileBrand(),
                        const SizedBox(height: 22),
                        _loginCard(),
                      ]);
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: desktop ? 20 : 20,
                vertical: desktop ? 28 : 24,
              ),
              child: Center(
                child: SizedBox(
                  width: (constraints.maxWidth - 40).clamp(0, 1240),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: desktop ? constraints.maxHeight - 56 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: desktop
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [body, const SizedBox(height: 18), _backLink()],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _brandMark({double size = 46}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(size * .32),
          border: Border.all(color: Colors.white.withValues(alpha: .2)),
        ),
        child: Icon(Icons.waves_rounded, color: Colors.white, size: size * .58),
      );

  Widget _mobileBrand() => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _brandMark(size: 40),
          const SizedBox(width: 10),
          const Text('ZanziConnect',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.6)),
        ]),
        const SizedBox(height: 10),
        const Text('Discover • Book • Experience Zanzibar',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xffe0f2ee),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ]);

  Widget _brandPanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            _brandMark(size: 52),
            const SizedBox(width: 14),
            const Text('ZanziConnect',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1)),
          ]),
          const SizedBox(height: 54),
          const Text('Discover • Book •\nExperience Zanzibar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 39,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.9)),
          const SizedBox(height: 17),
          const Text(
              "A clearer transaction journey for Zanzibar's tourism and coastal experiences.",
              style: TextStyle(
                  color: Color(0xffe0f2ee), fontSize: 16, height: 1.6)),
          const SizedBox(height: 24),
          const Text('ONE JOURNEY. ONE CONNECTED RECORD.',
              style: TextStyle(
                  color: Color(0xffffd99a),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          const Wrap(spacing: 10, runSpacing: 8, children: [
            _LifecycleLabel('DISCOVER'),
            _LifecycleArrow(),
            _LifecycleLabel('CHECK'),
            _LifecycleArrow(),
            _LifecycleLabel('BOOK'),
            _LifecycleArrow(),
            _LifecycleLabel('EXPERIENCE'),
            _LifecycleArrow(),
            _LifecycleLabel('RECORD'),
            _LifecycleArrow(),
            _LifecycleLabel('SETTLE'),
          ]),
          const SizedBox(height: 26),
          _passportPreview(),
        ],
      );

  Widget _passportPreview() => Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: Colors.white.withValues(alpha: .22)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.badge_outlined, color: Color(0xffffd99a), size: 19),
            SizedBox(width: 9),
            Text('TRIP PASSPORT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4)),
          ]),
          const SizedBox(height: 5),
          const Text('One connected transaction record',
              style: TextStyle(color: Color(0xffe0f2ee), fontSize: 12)),
          const SizedBox(height: 14),
          const Wrap(spacing: 14, runSpacing: 8, children: [
            _PassportStep('CHECK', true),
            _PassportStep('BOOKING RECORD', true),
            _PassportStep('EXPERIENCE', false),
            _PassportStep('SETTLEMENT', false),
          ]),
        ]),
      );

  Widget _loginCard() => Container(
        constraints: const BoxConstraints(maxWidth: 510),
        padding: const EdgeInsets.fromLTRB(34, 32, 34, 26),
        decoration: BoxDecoration(
          color: const Color(0xfffbfaf6),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 38,
                offset: const Offset(0, 17))
          ],
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: const Color(0xffe4f1ec),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.waves_rounded, color: _teal, size: 21)),
            const SizedBox(width: 12),
            const Text('ZanziConnect',
                style: TextStyle(
                    color: _ocean,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: -.2)),
          ]),
          const SizedBox(height: 23),
          const Text('Welcome Back',
              style: TextStyle(
                  color: _ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.6)),
          const SizedBox(height: 6),
          const Text('Log in to continue your ZanziConnect journey.',
              style: TextStyle(
                  color: Color(0xff657873), fontSize: 14, height: 1.5)),
          const SizedBox(height: 25),
          Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _FieldLabel('Email Address'),
                  const SizedBox(height: 7),
                  TextFormField(
                    key: const Key('login_email_field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                        'Enter your email address', Icons.mail_outline),
                    validator: _validateEmail,
                    onChanged: (_) => setState(() => _authError = null),
                  ),
                  const SizedBox(height: 17),
                  const _FieldLabel('Password'),
                  const SizedBox(height: 7),
                  TextFormField(
                    key: const Key('login_password_field'),
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration(
                            'Enter your password', Icons.lock_outline)
                        .copyWith(
                      suffixIcon: IconButton(
                        key: const Key('login_password_visibility'),
                        tooltip:
                            _showPassword ? 'Hide password' : 'Show password',
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                        icon: Icon(_showPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password is required.'
                        : null,
                    onChanged: (_) => setState(() => _authError = null),
                    onFieldSubmitted: (_) => _login(),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: _showForgotPassword,
                          child: const Text('Forgot Password?'))),
                  if (_authError != null) ...[
                    Container(
                      key: const Key('login_error'),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xffffeeee),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 18, color: Color(0xffb3261e)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(_authError!,
                                    style: const TextStyle(
                                        color: Color(0xff9f2822),
                                        fontWeight: FontWeight.w600))),
                          ]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 3),
                  FilledButton(
                    key: const Key('login_button'),
                    onPressed: _login,
                    style: FilledButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('LOG IN',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                          SizedBox(width: 9),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ]),
                  ),
                  const SizedBox(height: 17),
                  const Row(children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or',
                          style: TextStyle(
                              color: Color(0xff84918c), fontSize: 12)),
                    ),
                    Expanded(child: Divider())
                  ]),
                  const SizedBox(height: 10),
                  const Text('New to ZanziConnect?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xff657873), fontSize: 13)),
                  TextButton(
                    key: const Key('login_create_account_link'),
                    onPressed: _openRegistration,
                    style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        foregroundColor: _ocean),
                    child: const Text('CREATE ACCOUNT',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: .8)),
                  ),
                ]),
          ),
        ]),
      );

  Widget _backLink() => TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded, size: 17),
        label: const Text('Back to Welcome'),
        style: TextButton.styleFrom(foregroundColor: Colors.white),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 19, color: const Color(0xff73837e)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffdce5e0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      );

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    try {
      final account = DemoAccountStore.authenticate(
        _emailController.text,
        _passwordController.text,
      );
      if (account == null) {
        setState(() => _authError = 'Invalid email or password.');
        return;
      }
      widget.onAuthenticated(account);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      setState(() => _authError =
          'Unable to connect to ZanziConnect server. Please try again.');
    }
  }

  void _openRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateAccountScreen(
          onAuthenticated: widget.onAuthenticated,
        ),
      ),
    );
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password?'),
        content: const Text('Password reset will be added in a later step.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: Color(0xff344f56), fontSize: 13, fontWeight: FontWeight.w800));
}

class _LifecycleLabel extends StatelessWidget {
  final String label;
  const _LifecycleLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .5));
}

class _LifecycleArrow extends StatelessWidget {
  const _LifecycleArrow();

  @override
  Widget build(BuildContext context) => const Icon(Icons.arrow_forward_rounded,
      size: 13, color: Color(0xffffd99a));
}

class _PassportStep extends StatelessWidget {
  final String label;
  final bool complete;
  const _PassportStep(this.label, this.complete);

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(complete ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: complete ? const Color(0xffffd99a) : Colors.white60),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: .35)),
      ]);
}
