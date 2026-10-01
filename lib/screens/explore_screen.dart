import 'package:flutter/material.dart';

const _ocean = Color(0xff07509a);
const _teal = Color(0xff087fb8);
const _sand = Color(0xfff5f2ea);
const _ink = Color(0xff17343a);

class ExploreExperience {
  final int id;
  final String title;
  final String provider;
  final String location;
  final int price;
  final int guests;
  final List<String> categories;
  final String description;
  final bool bookingEligible;
  final String? unavailableReason;

  const ExploreExperience({
    required this.id,
    required this.title,
    required this.provider,
    required this.location,
    required this.price,
    required this.guests,
    required this.categories,
    required this.description,
    required this.bookingEligible,
    this.unavailableReason,
  });
}

const demoEligibleExperience = ExploreExperience(
  id: 1,
  title: 'Sunset Dhow Cruise',
  provider: 'Nungwi Blue Dhow',
  location: 'Nungwi, Zanzibar',
  price: 200000,
  guests: 2,
  categories: ['Dhow', 'Marine'],
  description:
      'A golden-hour dhow sailing along the coast. Includes a guide, refreshments and harbour fee.',
  bookingEligible: true,
);

const _experiences = [
  demoEligibleExperience,
  ExploreExperience(
    id: 2,
    title: 'Reef Discovery Sail',
    provider: 'Demo Ocean Adventures',
    location: 'Zanzibar',
    price: 180000,
    guests: 2,
    categories: ['Marine'],
    description: 'Illustrative marine experience listing.',
    bookingEligible: false,
    unavailableReason: 'Required provider document has expired.',
  ),
];

class ExploreScreen extends StatefulWidget {
  final Future<void> Function(BuildContext, ExploreExperience) book;
  final int? bookedExperienceId;
  final VoidCallback passport;

  const ExploreScreen({
    required this.book,
    required this.bookedExperienceId,
    required this.passport,
    super.key,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _categories = [
    'All',
    'Marine',
    'Dhow',
    'Culture',
    'Tours',
    'Food',
    'Wellness',
  ];

  final _searchController = TextEditingController();
  String _category = 'All';
  ExploreExperience? _selectedExperience;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _sand,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: _sand,
                foregroundColor: _ink,
                title: const Text('Explore Zanzibar',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                actions: const [
                  _ExploreDemoBadge(),
                  SizedBox(width: 18),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: _selectedExperience == null
                          ? _buildListing()
                          : _buildDetails(_selectedExperience!),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildListing() {
    final query = _searchController.text.trim().toLowerCase();
    final results = _experiences.where((experience) {
      final categoryMatches =
          _category == 'All' || experience.categories.contains(_category);
      final searchData =
          '${experience.title} ${experience.provider} ${experience.location}'
              .toLowerCase();
      return categoryMatches && (query.isEmpty || searchData.contains(query));
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text(
        'Discover coastal experiences with clear booking terms and connected trip records.',
        style: TextStyle(color: Color(0xff63746f), fontSize: 14, height: 1.5),
      ),
      const SizedBox(height: 5),
      const Text('ZANZIBAR  •  TANZANIA',
          style: TextStyle(
              color: _teal,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4)),
      const SizedBox(height: 18),
      TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search experiences...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xffdce5e0))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xffdce5e0))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: _teal, width: 1.5)),
        ),
      ),
      const SizedBox(height: 13),
      SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = category == _category;
            return ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => setState(() => _category = category),
              selectedColor: _ocean,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : const Color(0xff455e63),
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
              side: BorderSide(
                  color: selected ? _ocean : const Color(0xffdce5e0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              showCheckmark: false,
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      Row(children: [
        const Expanded(
            child: Text('Coastal experiences',
                style: TextStyle(
                    color: _ink, fontSize: 20, fontWeight: FontWeight.w900))),
        Text(
            '${results.length} ${results.length == 1 ? 'experience' : 'experiences'}',
            style: const TextStyle(color: Color(0xff71817c), fontSize: 11)),
      ]),
      const SizedBox(height: 12),
      if (results.isEmpty)
        _emptyState()
      else
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 760 ? 2 : 1;
          const gap = 16.0;
          final cardWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: results
                .map((experience) => SizedBox(
                    width: cardWidth,
                    child: _experienceCard(context, experience)))
                .toList(),
          );
        }),
    ]);
  }

  Widget _experienceCard(BuildContext context, ExploreExperience experience) {
    final isBooked = widget.bookedExperienceId == experience.id;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .055),
              blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _experienceVisual(experience),
        Padding(
          padding: const EdgeInsets.all(19),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _statusPill(
                  experience.bookingEligible
                      ? 'BOOKING ELIGIBLE'
                      : 'BOOKING UNAVAILABLE',
                  experience.bookingEligible),
              if (isBooked) ...[
                const SizedBox(width: 6),
                _statusPill('BOOKED ✓', true),
              ],
              const Spacer(),
              const Text('DEMO DATA',
                  style: TextStyle(
                      color: Color(0xff89958f),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8)),
            ]),
            const SizedBox(height: 12),
            Text(experience.title,
                style: const TextStyle(
                    color: _ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.3)),
            const SizedBox(height: 4),
            Text(experience.provider,
                style: const TextStyle(color: Color(0xff63746f), fontSize: 13)),
            const SizedBox(height: 12),
            Wrap(spacing: 15, runSpacing: 8, children: [
              _experienceFact(Icons.location_on_outlined, experience.location),
              _experienceFact(
                  Icons.people_outline, '${experience.guests} guests'),
              _experienceFact(
                  Icons.sell_outlined, experience.categories.join(' · ')),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: Text('TZS ${_formatPrice(experience.price)}',
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900))),
              TextButton(
                onPressed: () =>
                    setState(() => _selectedExperience = experience),
                child: const Text('VIEW DETAILS',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ]),
            if (experience.unavailableReason != null) ...[
              const SizedBox(height: 5),
              Text(experience.unavailableReason!,
                  style: const TextStyle(
                      color: Color(0xff9a572a), fontSize: 11, height: 1.4)),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isBooked
                    ? widget.passport
                    : experience.bookingEligible
                        ? () => widget.book(context, experience)
                        : null,
                icon: Icon(
                    isBooked
                        ? Icons.badge_outlined
                        : Icons.arrow_forward_rounded,
                    size: 17),
                label: Text(isBooked ? 'VIEW TRIP' : 'BOOK NOW'),
                style: FilledButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6),
                ),
              ),
            ),
            if (!experience.bookingEligible)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _showRequirements(context, experience),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('VIEW REQUIREMENTS'),
                ),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDetails(ExploreExperience experience) {
    final isBooked = widget.bookedExperienceId == experience.id;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => setState(() => _selectedExperience = null),
          icon: const Icon(Icons.arrow_back_rounded, size: 17),
          label: const Text('BACK TO EXPERIENCES'),
        ),
      ),
      const SizedBox(height: 7),
      _experienceVisual(experience, height: 230),
      const SizedBox(height: 18),
      Wrap(spacing: 9, runSpacing: 8, children: [
        _statusPill(
            experience.bookingEligible
                ? 'BOOKING ELIGIBLE'
                : 'BOOKING UNAVAILABLE',
            experience.bookingEligible),
        if (isBooked) _statusPill('BOOKED ✓', true),
        const _ExploreDemoPill(),
      ]),
      const SizedBox(height: 10),
      Text(experience.title,
          style: const TextStyle(
              color: _ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5)),
      Text('${experience.provider} · ${experience.location}',
          style: const TextStyle(color: Color(0xff63746f), fontSize: 14)),
      const SizedBox(height: 15),
      Text(experience.description,
          style: const TextStyle(
              color: Color(0xff3f555a), fontSize: 14, height: 1.6)),
      const SizedBox(height: 15),
      Wrap(spacing: 14, runSpacing: 10, children: [
        _detailChip(Icons.people_outline, '${experience.guests} guests'),
        _detailChip(Icons.category_outlined, experience.categories.join(' · ')),
        _detailChip(
            Icons.sell_outlined, 'TZS ${_formatPrice(experience.price)}'),
      ]),
      const SizedBox(height: 16),
      if (experience.bookingEligible)
        _detailCheckCard()
      else if (experience.unavailableReason != null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xffffefdf),
              borderRadius: BorderRadius.circular(15)),
          child: Text('Booking unavailable: ${experience.unavailableReason}',
              style: const TextStyle(
                  color: Color(0xff774b30), fontSize: 12, height: 1.45)),
        ),
      const SizedBox(height: 18),
      Wrap(spacing: 12, runSpacing: 10, children: [
        OutlinedButton.icon(
          onPressed: widget.passport,
          icon: const Icon(Icons.badge_outlined),
          label: const Text('TRIP PASSPORT'),
        ),
        FilledButton.icon(
          onPressed: isBooked
              ? widget.passport
              : experience.bookingEligible
                  ? () => widget.book(context, experience)
                  : null,
          icon: Icon(
              isBooked ? Icons.badge_outlined : Icons.arrow_forward_rounded),
          label: Text(isBooked ? 'VIEW TRIP' : 'BOOK NOW'),
        ),
        if (!experience.bookingEligible)
          OutlinedButton.icon(
            onPressed: () => _showRequirements(context, experience),
            icon: const Icon(Icons.info_outline),
            label: const Text('VIEW REQUIREMENTS'),
          ),
      ]),
    ]);
  }

  Widget _detailCheckCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Required booking checks complete',
                  style: TextStyle(color: _ink, fontWeight: FontWeight.w800)),
              SizedBox(height: 6),
              Text(
                  'Provider record active · Documents valid · Capacity available · Departure conditions checked',
                  style: TextStyle(
                      color: Color(0xff63746f), fontSize: 12, height: 1.5)),
            ]),
      );

  Widget _experienceVisual(ExploreExperience experience,
          {double height = 164}) =>
      Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: experience.bookingEligible
                ? const [Color(0xff0a597b), Color(0xff35a9a6)]
                : const [Color(0xff456978), Color(0xff8ca2a0)],
          ),
        ),
        child: Stack(children: [
          Positioned(
              right: 14,
              top: 10,
              child: Icon(Icons.wb_sunny_rounded,
                  size: 28, color: Colors.white.withValues(alpha: .6))),
          Center(
              child: Icon(
                  experience.categories.contains('Dhow')
                      ? Icons.sailing_rounded
                      : Icons.water_rounded,
                  size: height * .48,
                  color: const Color(0xffe7f3e9))),
          Positioned(
              left: 15,
              bottom: 12,
              child: Text(experience.location.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2))),
        ]),
      );

  Widget _statusPill(String label, bool eligible) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: eligible ? const Color(0xffe8f4ee) : const Color(0xffffeee3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: eligible
                    ? const Color(0xff207653)
                    : const Color(0xff99582e),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .5)),
      );

  Widget _experienceFact(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _teal, size: 15),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: Color(0xff63746f), fontSize: 10)),
      ]);

  Widget _detailChip(IconData icon, String text) => Chip(
        avatar: Icon(icon, color: _teal, size: 15),
        label: Text(text),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xffe1e9e5)),
        labelStyle: const TextStyle(fontSize: 11, color: _ink),
      );

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: const Column(children: [
          Icon(Icons.search_off_rounded, color: _teal, size: 32),
          SizedBox(height: 10),
          Text('No experiences found',
              style: TextStyle(
                  color: _ink, fontWeight: FontWeight.w900, fontSize: 16)),
          SizedBox(height: 4),
          Text('Try another search or category.',
              style: TextStyle(color: Color(0xff71817c), fontSize: 12)),
        ]),
      );

  void _showRequirements(BuildContext context, ExploreExperience experience) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Booking requirements',
                    style: TextStyle(
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text(experience.unavailableReason ??
                    'Required records are not ready.'),
                const SizedBox(height: 8),
                const Text(
                    'ZanziConnect checks records required for its booking process. It does not replace government certification or inspection authorities.',
                    style: TextStyle(
                        color: Color(0xff63746f), fontSize: 12, height: 1.5)),
              ]),
        ),
      ),
    );
  }

  String _formatPrice(int price) => price
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
}

class _ExploreDemoBadge extends StatelessWidget {
  const _ExploreDemoBadge();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: const Color(0xffe6efeb),
            borderRadius: BorderRadius.circular(20)),
        child: const Text('DEMO MODE',
            style: TextStyle(
                color: _ocean,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
      );
}

class _ExploreDemoPill extends StatelessWidget {
  const _ExploreDemoPill();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xffeef1ef),
            borderRadius: BorderRadius.circular(20)),
        child: const Text('DEMO DATA',
            style: TextStyle(
                color: Color(0xff6d7c77),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .7)),
      );
}
