import 'package:flutter/material.dart';

import '../models/registered_account.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  final ValueChanged<RegisteredAccount> onAuthenticated;

  const CreateAccountScreen({required this.onAuthenticated, super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const _ocean = Color(0xff07509a);
  static const _teal = Color(0xff087fb8);
  static const _sand = Color(0xfff5f2ea);
  static const _ink = Color(0xff14313d);

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  AccountRole? _role;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  String? _registrationError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
            final desktop = constraints.maxWidth >= 980;
            final content = desktop
                ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(child: _brandPanel()),
                    const SizedBox(width: 42),
                    Expanded(child: Center(child: _formCard(desktop: true))),
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        _compactBrand(),
                        const SizedBox(height: 20),
                        _formCard(desktop: false),
                      ]);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Center(
                child: SizedBox(
                  width: (constraints.maxWidth - 40).clamp(0, 1240),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: desktop ? constraints.maxHeight - 44 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: desktop
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        content,
                        const SizedBox(height: 12),
                        _backToWelcome()
                      ],
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

  Widget _brandMark({double size = 48}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(size * .32),
          border: Border.all(color: Colors.white.withValues(alpha: .2)),
        ),
        child: Icon(Icons.waves_rounded, color: Colors.white, size: size * .58),
      );

  Widget _compactBrand() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _brandMark(size: 40),
          const SizedBox(width: 10),
          const Text('ZanziConnect',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.6)),
        ],
      );

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
          const SizedBox(height: 40),
          const Text('Discover • Book •\nExperience Zanzibar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.9)),
          const SizedBox(height: 16),
          const Text(
              'Join a connected tourism and coastal experience ecosystem.',
              style: TextStyle(
                  color: Color(0xffe0f2ee), fontSize: 16, height: 1.6)),
          const SizedBox(height: 22),
          const Text('ONE JOURNEY. ONE CONNECTED RECORD.',
              style: TextStyle(
                  color: Color(0xffffd99a),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4)),
          const SizedBox(height: 11),
          const Wrap(spacing: 9, runSpacing: 8, children: [
            _LifecycleItem('DISCOVER'),
            _ArrowMark(),
            _LifecycleItem('CHECK'),
            _ArrowMark(),
            _LifecycleItem('BOOK'),
            _ArrowMark(),
            _LifecycleItem('EXPERIENCE'),
            _ArrowMark(),
            _LifecycleItem('RECORD'),
            _ArrowMark(),
            _LifecycleItem('SETTLE'),
          ]),
          const SizedBox(height: 21),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .2)),
            ),
            child: const Row(children: [
              Icon(Icons.badge_outlined, color: Color(0xffffd99a), size: 22),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('TRIP PASSPORT',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3)),
                    SizedBox(height: 4),
                    Text('A connected record from booking through settlement.',
                        style: TextStyle(
                            color: Color(0xffe0f2ee),
                            fontSize: 12,
                            height: 1.4)),
                  ])),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('VISITORS  ·  Discover and book experiences',
              style:
                  TextStyle(color: Colors.white70, fontSize: 12, height: 1.7)),
          const Text('PROVIDERS  ·  Offer and manage experiences',
              style:
                  TextStyle(color: Colors.white70, fontSize: 12, height: 1.7)),
        ],
      );

  Widget _formCard({required bool desktop}) => Container(
        constraints: const BoxConstraints(maxWidth: 650),
        padding: EdgeInsets.all(desktop ? 30 : 21),
        decoration: BoxDecoration(
          color: const Color(0xfffbfaf6),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .19),
                blurRadius: 36,
                offset: const Offset(0, 16))
          ],
        ),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: const Color(0xffe4f1ec),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_add_alt_1_rounded,
                      color: _teal, size: 20)),
              const SizedBox(width: 11),
              const Text('ZanziConnect',
                  style: TextStyle(
                      color: _ocean,
                      fontSize: 14,
                      fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 18),
            const Text('Create Your Account',
                style: TextStyle(
                    color: _ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.5)),
            const SizedBox(height: 5),
            const Text('Join ZanziConnect and start your journey.',
                style: TextStyle(
                    color: Color(0xff657873), fontSize: 13, height: 1.5)),
            const SizedBox(height: 21),
            if (desktop) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _firstNameField()),
                const SizedBox(width: 13),
                Expanded(child: _lastNameField()),
              ]),
              const SizedBox(height: 13),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _emailField()),
                const SizedBox(width: 13),
                Expanded(child: _phoneField()),
              ]),
              const SizedBox(height: 13),
              _roleField(),
              if (_role != null) _roleDescription(),
              const SizedBox(height: 13),
              _passwordField(),
              const SizedBox(height: 13),
              _confirmPasswordField(),
            ] else ...[
              _firstNameField(),
              const SizedBox(height: 13),
              _lastNameField(),
              const SizedBox(height: 13),
              _emailField(),
              const SizedBox(height: 13),
              _phoneField(),
              const SizedBox(height: 13),
              _passwordField(),
              const SizedBox(height: 13),
              _confirmPasswordField(),
              const SizedBox(height: 13),
              _roleField(),
              if (_role != null) _roleDescription(),
            ],
            const SizedBox(height: 17),
            if (_registrationError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xffffeeee),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: Color(0xffb3261e)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_registrationError!,
                          style: const TextStyle(
                              color: Color(0xff9f2822),
                              fontWeight: FontWeight.w600))),
                ]),
              ),
              const SizedBox(height: 12),
            ],
            const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline, size: 15, color: Color(0xff74857f)),
              SizedBox(width: 7),
              Expanded(
                  child: Text(
                      'Your account information is used to provide your ZanziConnect experience.',
                      style: TextStyle(
                          color: Color(0xff74857f),
                          fontSize: 11,
                          height: 1.4))),
            ]),
            const SizedBox(height: 14),
            FilledButton(
              key: const Key('create_account_button'),
              onPressed: _createAccount,
              style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('CREATE ACCOUNT',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: .8)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ]),
            ),
            const SizedBox(height: 14),
            const Row(children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 11),
                child: Text('or',
                    style: TextStyle(color: Color(0xff89958f), fontSize: 12)),
              ),
              Expanded(child: Divider())
            ]),
            const SizedBox(height: 7),
            Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Already have an account?',
                      style: TextStyle(color: Color(0xff657873), fontSize: 13)),
                  TextButton(
                      key: const Key('login_link'),
                      onPressed: () => _openLogin(context),
                      child: const Text('LOG IN',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: .6))),
                ]),
          ]),
        ),
      );

  Widget _firstNameField() => _labeledField(
      'First Name',
      TextFormField(
        key: const Key('first_name_field'),
        controller: _firstNameController,
        textCapitalization: TextCapitalization.words,
        decoration: _inputDecoration('Your first name', Icons.person_outline),
        validator: (value) => _required(value, 'First name'),
      ));

  Widget _lastNameField() => _labeledField(
      'Last Name',
      TextFormField(
        key: const Key('last_name_field'),
        controller: _lastNameController,
        textCapitalization: TextCapitalization.words,
        decoration: _inputDecoration('Your last name', Icons.person_outline),
        validator: (value) => _required(value, 'Last name'),
      ));

  Widget _emailField() => _labeledField(
      'Email Address',
      TextFormField(
        key: const Key('email_field'),
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: _inputDecoration('name@example.com', Icons.mail_outline),
        validator: _validateEmail,
      ));

  Widget _phoneField() => _labeledField(
      'Phone Number',
      TextFormField(
        key: const Key('phone_field'),
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: _inputDecoration('+255 ...', Icons.phone_outlined),
        validator: (value) => _required(value, 'Phone number'),
      ));

  Widget _passwordField() => _labeledField(
      'Password',
      TextFormField(
        key: const Key('password_field'),
        controller: _passwordController,
        obscureText: !_showPassword,
        autofillHints: const [AutofillHints.newPassword],
        decoration:
            _inputDecoration('Create a password', Icons.lock_outline).copyWith(
          suffixIcon: IconButton(
              key: const Key('password_visibility_button'),
              tooltip: _showPassword ? 'Hide password' : 'Show password',
              onPressed: () => setState(() => _showPassword = !_showPassword),
              icon: Icon(_showPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined)),
        ),
        validator: (value) => _required(value, 'Password'),
      ));

  Widget _confirmPasswordField() => _labeledField(
      'Confirm Password',
      TextFormField(
        key: const Key('confirm_password_field'),
        controller: _confirmController,
        obscureText: !_showConfirmPassword,
        decoration:
            _inputDecoration('Enter your password again', Icons.lock_outline)
                .copyWith(
          suffixIcon: IconButton(
              key: const Key('confirm_password_visibility_button'),
              tooltip: _showConfirmPassword ? 'Hide password' : 'Show password',
              onPressed: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
              icon: Icon(_showConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined)),
        ),
        validator: _validatePasswordConfirmation,
      ));

  Widget _roleField() => _labeledField(
      'I want to join as',
      DropdownButtonFormField<AccountRole>(
        key: const Key('role_dropdown'),
        initialValue: _role,
        isExpanded: true,
        decoration: _inputDecoration('Select a role', Icons.groups_outlined),
        items: publicRegistrationRoles
            .map((role) => DropdownMenuItem<AccountRole>(
                  value: role,
                  child: Text(role.label),
                ))
            .toList(),
        onChanged: (role) => setState(() => _role = role),
        validator: (role) => role == null ? 'Select your role.' : null,
      ));

  Widget _roleDescription() => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(_role!.description,
            key: const Key('role_description'),
            style: const TextStyle(
                color: Color(0xff61736f), fontSize: 11, height: 1.4)),
      );

  Widget _labeledField(String label, Widget field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(label,
                  style: const TextStyle(
                      color: Color(0xff344f56),
                      fontSize: 12,
                      fontWeight: FontWeight.w800))),
          field,
        ],
      );

  Widget _backToWelcome() => TextButton.icon(
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        icon: const Icon(Icons.arrow_back_rounded, size: 16),
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xffdce5e0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      );

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required.' : null;

  String? _validateEmail(String? value) {
    final requiredError = _required(value, 'Email');
    if (requiredError != null) return requiredError;
    final validEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return validEmail.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address.';
  }

  String? _validatePasswordConfirmation(String? value) {
    final requiredError = _required(value, 'Confirm password');
    if (requiredError != null) return requiredError;
    return value == _passwordController.text ? null : 'Passwords do not match.';
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate() || _role == null) return;

    final account = DemoAccountStore.newAccount(
      fullName:
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _role!,
    );
    final registered =
        DemoAccountStore.register(account, _passwordController.text);
    if (!registered) {
      setState(() => _registrationError =
          'An account with this email already exists. Log in instead.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(
          onAuthenticated: widget.onAuthenticated,
        ),
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(
          onAuthenticated: widget.onAuthenticated,
        ),
      ),
    );
  }
}

class _LifecycleItem extends StatelessWidget {
  final String label;
  const _LifecycleItem(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .45));
}

class _ArrowMark extends StatelessWidget {
  const _ArrowMark();

  @override
  Widget build(BuildContext context) => const Icon(Icons.arrow_forward_rounded,
      size: 13, color: Color(0xffffd99a));
}
