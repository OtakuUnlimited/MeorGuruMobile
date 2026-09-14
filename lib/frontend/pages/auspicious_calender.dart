import 'package:flutter/material.dart';
import 'package:nepali_utils/nepali_utils.dart';

import '../../backend/services/content_services.dart';
import '../components/top_nav_bar.dart';
import '../components/bottom_nav_bar.dart';

class AuspiciousCalender extends StatefulWidget {
  const AuspiciousCalender({super.key});

  @override
  State<AuspiciousCalender> createState() => _AuspiciousCalenderState();
}

class _Option {
  const _Option(this.value, this.label);
  final String value;
  final String label;
}

class _Ritual {
  const _Ritual(this.id, this.title, this.image);
  final String id;
  final String title;
  final String image;

  factory _Ritual.fromJson(Map<String, dynamic> j) => _Ritual(
        '${j['id'] ?? ''}',
        '${j['title'] ?? j['name'] ?? ''}',
        '${j['image'] ?? ''}',
      );
}

const _allRitual = _Ritual('all', 'All Rituals', '');

class _Day {
  const _Day({
    required this.ad,
    required this.bs,
    required this.name,
    required this.image,
    this.tithi = '',
    this.nakshatra = '',
    this.description = '',
  });
  final DateTime ad;
  final String bs;
  final String name;
  final String image;
  final String tithi;
  final String nakshatra;
  final String description;
}

class _AuspiciousCalenderState extends State<AuspiciousCalender> {
  static const orange = Color(0xFFFF5A00);
  static const red = Color(0xFFD4202B);
  static const ink = Color(0xFF17191B);
  static const tile = Color(0xFFF4F4F5);
  static const muted = Color(0xFF607782);

  final ContentService contentService = ContentService();
  bool loadingFilters = true;
  bool loadingDates = false;
  String? error;

  List<_Ritual> rituals = const [];
  List<_Option> countries = const [];
  List<_Option> years = const [];
  List<_Option> months = const [];
  List<_Day> days = const [];
  _Ritual? ritual;
  _Option? country;
  _Option? year;
  _Option? month;
  DateTime shown = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selected = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadFilters();
  }

  Map<String, dynamic> asMap(dynamic item) =>
      Map<String, dynamic>.from(item as Map);

  _Option parseOption(dynamic raw, String type) {
    if (raw is String || raw is num) return _Option('$raw', '$raw');
    final j = asMap(raw);
    final id = j['id'];
    final label = type == 'year'
        ? (j['year'] ?? j['title'] ?? j['name'] ?? id)
        : type == 'month'
            ? (j['month'] ?? j['title'] ?? j['name'] ?? id)
            : (j['country_name'] ?? j['country'] ?? j['title'] ?? j['name'] ?? id);
    return _Option('${type == 'country' ? id : label}', '$label');
  }

  Future<void> loadFilters() async {
    setState(() {
      loadingFilters = true;
      error = null;
    });
    try {
      final all = await Future.wait([
        contentService.fetchAllRituals(),
        contentService.fetchCountries(),
        contentService.fetchAuspiciousYears(),
        contentService.fetchAuspiciousMonths(),
      ]);
      final newRituals = (all[0] as List<dynamic>)
          .map((e) => _Ritual.fromJson(asMap(e)))
          .where((e) => e.id.isNotEmpty)
          .toList();
      final newCountries = (all[1] as List<dynamic>)
          .map((e) => parseOption(e, 'country'))
          .toList();
      final newYears = (all[2] as List<dynamic>).map((e) => parseOption(e, 'year')).toList();
      final newMonths = (all[3] as List<dynamic>).map((e) => parseOption(e, 'month')).toList();
      if (!mounted) return;
      setState(() {
        rituals = newRituals;
        countries = newCountries;
        years = newYears;
        months = newMonths;
        ritual = _allRitual;
        country = newCountries.firstOrNull;
        year = findOption(newYears, '${DateTime.now().year}');
        month = findOption(newMonths, monthName(DateTime.now().month));
        syncMonth();
        loadingFilters = false;
      });
      if (canSearch) await loadDates();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingFilters = false;
        error = '$e';
      });
    }
  }

  _Option? findOption(List<_Option> options, String target) {
    if (options.isEmpty) return null;
    final wanted = target.toLowerCase();
    for (final option in options) {
      if (option.value.toLowerCase() == wanted ||
          option.label.toLowerCase() == wanted) return option;
    }
    return options.first;
  }

  bool get canSearch =>
      ritual != null && country != null && year != null && month != null;

  Future<void> loadDates() async {
    if (!canSearch) return;
    setState(() {
      loadingDates = true;
      error = null;
    });
    try {
      final response = await contentService.fetchRitualAuspiciousDates(
        ritualId: ritual!.id,
        countryId: int.parse(country!.value),
        year: year!.value,
        month: month!.value,
      );
      final loaded = response
          .map(parseDay)
          .whereType<_Day>()
          .toList();
      loaded.sort((a, b) => a.ad.compareTo(b.ad));
      if (!mounted) return;
      setState(() {
        days = loaded;
        loadingDates = false;
        syncMonth();
        if (loaded.isNotEmpty) selected = loaded.first.ad;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingDates = false;
        error = '$e';
      });
    }
  }

  _Day? parseDay(dynamic raw) {
    final j = asMap(raw);
    final parsed = DateTime.tryParse(
        '${j['eng_date'] ?? j['english_date'] ?? j['date'] ?? ''}');
    if (parsed == null) return null;
    return _Day(
      ad: DateTime(parsed.year, parsed.month, parsed.day),
      bs: '${j['nep_date'] ?? j['nepali_date'] ?? ''}',
      name: '${j['ritual_name'] ?? j['title'] ?? ritual?.title ?? ''}',
      image: '${j['image'] ?? ritual?.image ?? ''}',
      tithi: '${j['tithi'] ?? ''}',
      nakshatra: '${j['nakshatra'] ?? ''}',
      description: '${j['description'] ?? ''}',
    );
  }

  void syncMonth() {
    final y = int.tryParse(year?.value ?? '') ?? DateTime.now().year;
    final m = monthNumber(month?.label ?? '') ?? DateTime.now().month;
    shown = DateTime(y, m);
    selected = DateTime(y, m, 1);
  }

  Map<String, List<_Day>> get dayMap {
    final result = <String, List<_Day>>{};
    for (final day in days) {
      result.putIfAbsent(dateKey(day.ad), () => []).add(day);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomTopNavBar(
          title: 'Mero Guru',
          style: NavBarStyle.BrandedLight,
          showMenu: true,
          showCart: true,
          showProfile: true,
        ),
        body: SafeArea(
          child: loadingFilters
              ? const Center(child: CircularProgressIndicator(color: orange))
              : RefreshIndicator(
                  color: orange,
                  onRefresh: loadFilters,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Auspicious Dates', style: TextStyle(color: orange, fontSize: 28, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 20),
                            filters(),
                            if (error != null) errorBox(),
                            const SizedBox(height: 15),
                            const Center(
                              child: Text(
                                'Auspicious dates for the rituals will be highlighted in green below',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF388E3C), fontStyle: FontStyle.italic),
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (loadingDates)
                              const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: orange)))
                            else ...[
                              calendar(),
                              const SizedBox(height: 28),
                              details(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                ),
                
        ),
        bottomNavigationBar: const CustomBottomNavBar(
        activeIndex: 3,
      ),
      );

  Widget introSection() => Column(children: [
        const Text(
          'Auspicious Dates for Hindu Rituals and Celebration',
          textAlign: TextAlign.center,
          style: TextStyle(color: orange, fontSize: 36, height: 1.15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 13),
        const Text(
          'Discover the best dates and times for rituals, festivals, and celebrations as per the Hindu Panchang. Plan your special moments with spiritual precision and confidence.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF555555), fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: const [
            _StepPill('01', 'Select the Ritual'),
            _StepPill('02', 'Select Country'),
            _StepPill('03', 'Select Year'),
            _StepPill('04', 'Select Month'),
            _StepPill('05', 'Find Results'),
          ],
        ),
      ]);

  Widget popularRituals() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 30, 14, 34),
        decoration: BoxDecoration(color: const Color(0xFFF7F7F7), borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          const Text('Popular Rituals', style: TextStyle(color: orange, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (_, box) {
            final columns = box.maxWidth >= 650 ? 4 : box.maxWidth >= 430 ? 3 : 2;
            final cardWidth = (box.maxWidth - ((columns - 1) * 12)) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 20,
              children: rituals.map((item) {
                final active = ritual?.id == item.id;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => ritual = item),
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: active ? orange : Colors.transparent, width: 2.5),
                        ),
                        child: networkImage(item.image, cardWidth, 105),
                      ),
                      const SizedBox(height: 7),
                      Text(item.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: active ? orange : const Color(0xFF333333), fontSize: 14, fontWeight: active ? FontWeight.w800 : FontWeight.w600)),
                    ]),
                  ),
                );
              }).toList(),
            );
          }),
          
        ]),
        
      );

  Widget filters() => LayoutBuilder(builder: (_, box) {
        final width = box.maxWidth < 560 ? box.maxWidth : (box.maxWidth - 12) / 2;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: width, child: ritualDropdown()),
          SizedBox(width: width, child: optionDropdown('Country', countries, country, (v) => country = v)),
          SizedBox(width: width, child: optionDropdown('Year', years, year, (v) => year = v)),
          SizedBox(width: width, child: optionDropdown('Month', months, month, (v) => month = v)),
          SizedBox(
            width: box.maxWidth,
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC3242B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: canSearch ? loadDates : null,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Show auspicious dates', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ]);
      });

  Widget ritualDropdown() => DropdownButtonFormField<_Ritual>(
        value: ritual,
        isExpanded: true,
        decoration: inputDecoration('Ritual'),
        items: [_allRitual, ...rituals].map((r) => DropdownMenuItem(
          value: r,
          child: Row(children: [
            networkImage(r.image, 34, 34),
            const SizedBox(width: 9),
            Expanded(child: Text(r.title, overflow: TextOverflow.ellipsis)),
          ]),
        )).toList(),
        onChanged: (v) => setState(() => ritual = v),
      );

  Widget optionDropdown(String label, List<_Option> list, _Option? value, void Function(_Option?) save) => DropdownButtonFormField<_Option>(
        value: value,
        isExpanded: true,
        decoration: inputDecoration(label),
        items: list.map((v) => DropdownMenuItem(value: v, child: Text(v.label, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) => setState(() {
          save(v);
          if (label == 'Year' || label == 'Month') syncMonth();
        }),
      );

  InputDecoration inputDecoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: tile,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );

  Widget calendar() {
    final first = DateTime(shown.year, shown.month, 1);
    final count = DateTime(shown.year, shown.month + 1, 0).day;
    final leading = first.weekday % 7;
    final cells = ((leading + count + 6) ~/ 7) * 7;
    const headers = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final firstBs = first.toNepaliDateTime();
    final lastBs = DateTime(shown.year, shown.month, count).toNepaliDateTime();
    final bsMonths = firstBs.month == lastBs.month
        ? nepaliMonthName(firstBs.month)
        : '${nepaliMonthName(firstBs.month)} / ${nepaliMonthName(lastBs.month)}';
    final bsYears = firstBs.year == lastBs.year ? '${firstBs.year}' : '${firstBs.year} / ${lastBs.year}';
    return Column(children: [
      Row(children: [
        Expanded(child: Text('${monthName(shown.month)} ${shown.year} (AD)', style: const TextStyle(color: ink, fontSize: 20, fontWeight: FontWeight.w800))),
        Expanded(child: Text('$bsMonths $bsYears (BS)', textAlign: TextAlign.end, style: const TextStyle(color: Color(0xFF2C7A2C), fontSize: 17, fontWeight: FontWeight.w800))),
      ]),
      const SizedBox(height: 14),
      Row(children: headers.asMap().entries.map((entry) => Expanded(child: Center(child: Text(entry.value, style: TextStyle(color: entry.key == 0 || entry.key == 6 ? Colors.red : const Color(0xFF555555), fontSize: 12, fontWeight: FontWeight.w800))))).toList()),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cells,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 4, mainAxisSpacing: 4, childAspectRatio: .58),
        itemBuilder: (_, index) {
          final number = index - leading + 1;
          if (number < 1 || number > count) return const SizedBox.shrink();
          final date = DateTime(shown.year, shown.month, number);
          final matches = dayMap[dateKey(date)] ?? const <_Day>[];
          final isSelected = sameDate(date, selected);
          final hasRitual = matches.isNotEmpty;
          final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
          final nepaliDate = date.toNepaliDateTime();
          final serverBs = matches.firstOrNull?.bs ?? '';
          final bsText = serverBs.isNotEmpty
              ? formatBsDate(serverBs)
              : '${nepaliDate.day} ${nepaliMonthName(nepaliDate.month)} ${nepaliDate.year}';
          final ritualNames = matches.map((e) => e.name).where((e) => e.isNotEmpty).join(' / ');
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => selected = date),
            child: Container(
              decoration: BoxDecoration(
                color: hasRitual
                    ? const Color(0xFFD4EDDA)
                    : isSelected
                        ? const Color(0xFFFFE9DF)
                        : tile,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: hasRitual
                      ? const Color(0xFF388E3C)
                      : isSelected
                          ? orange
                          : const Color(0xFFD3D3D3),
                  width: hasRitual || isSelected ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$number', style: TextStyle(color: hasRitual || isWeekend ? Colors.red : ink, fontSize: 20, height: 1, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(bsText, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF555555), fontSize: 8.5, height: 1.15)),
                if (hasRitual && ritualNames.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(ritualNames, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFE80700), fontSize: 8, height: 1.1, fontWeight: FontWeight.w700)),
                ],
              ]),
            ),
          );
        },
      ),
      
    ]);
    
  }

  Widget details() {
    final matches = dayMap[dateKey(selected)] ?? const <_Day>[];
    final convertedBs = selected.toNepaliDateTime();
    final convertedBsText = '${convertedBs.day} ${nepaliMonthName(convertedBs.month)} ${convertedBs.year}';
    final hasRitual = matches.isNotEmpty;
    final primaryMatch = matches.firstOrNull;
    final displayedBs = primaryMatch?.bs.isNotEmpty == true
        ? formatBsDate(primaryMatch!.bs)
        : convertedBsText;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(color: const Color(0xFFFFFCFB), borderRadius: BorderRadius.circular(34), boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 15, offset: Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        badge(hasRitual ? 'AUSPICIOUS DAY' : 'SELECTED DAY'),
        const SizedBox(height: 15),
        Text(displayedBs, style: const TextStyle(fontSize: 37, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        Text(
          '${weekday(selected.weekday)}, ${monthName(selected.month)} ${selected.day}, ${selected.year}',
          style: const TextStyle(color: muted, fontSize: 17),
        ),
        const SizedBox(height: 24),
        if (!hasRitual)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: tile, borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [
              Icon(Icons.event_available_outlined, color: muted),
              SizedBox(width: 12),
              Expanded(child: Text('No auspicious ritual recorded for this date.', style: TextStyle(color: muted))),
            ]),
          ),
        ...matches.map((r) => Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFFF2EE), borderRadius: BorderRadius.circular(22)),
                child: Row(children: [
                  networkImage(r.image, 58, 58),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.name, style: const TextStyle(color: Color(0xFFC42D00), fontSize: 17, fontWeight: FontWeight.w900)),
                    if (r.description.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(r.description, style: const TextStyle(color: Color(0xFFD46B50)))),
                  ])),
                ]),
              )),
      ]),
    );
  }

  Widget upcoming() {
    final sorted = [...days]..sort((a, b) => a.ad.compareTo(b.ad));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Upcoming Rituals', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 14),
      if (sorted.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('No upcoming rituals found', style: TextStyle(color: muted))),
        ),
      ...sorted.take(4).map((r) => Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tile, borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          networkImage(r.image, 72, 68),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('SHUBHA MUHURAT', style: TextStyle(color: Color(0xFFC42D00), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 6),
            Text(r.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
            Text('${weekday(r.ad.weekday)}, ${monthName(r.ad.month).substring(0, 3)} ${r.ad.day}', style: const TextStyle(color: muted)),
          ])),
          const Icon(Icons.chevron_right, color: Color(0xFFD3D5D6)),
        ]),
      )),
    ]);
  }

  Widget networkImage(String source, double width, double height) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: source.isEmpty
            ? Container(width: width, height: height, color: const Color(0xFFE7D6D0), child: const Icon(Icons.self_improvement, color: orange))
            : Image.network(source, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: width, height: height, color: const Color(0xFFE7D6D0), child: const Icon(Icons.broken_image_outlined))),
      );

  Widget errorBox() => Container(width: double.infinity, margin: const EdgeInsets.only(top: 14), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFFFE8E8), borderRadius: BorderRadius.circular(12)), child: Text(error!, style: const TextStyle(color: Color(0xFF9F1720))));
  Widget badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFFBE8E2), borderRadius: BorderRadius.circular(20)), child: Text('✦  $text', style: const TextStyle(color: Color(0xFFC23A16), fontSize: 12, fontWeight: FontWeight.w900)));
  Widget fact(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0xFFA6B2B8), letterSpacing: 1.3, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Text(value.isEmpty ? 'Not provided' : value, style: const TextStyle(fontWeight: FontWeight.w700))]);

  String dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  bool sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String formatBsDate(String value) {
    final parts = value.split('-');
    if (parts.length == 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null && m >= 1 && m <= 12) {
        return '$d ${nepaliMonthName(m)} $y';
      }
    }
    return value;
  }
  String nepaliMonthName(int value) => const [
    'बैशाख', 'जेठ', 'असार', 'साउन', 'भदौ', 'असोज',
    'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फागुन', 'चैत'
  ][value - 1];
  int? monthNumber(String value) {
    final number = int.tryParse(value);
    if (number != null && number >= 1 && number <= 12) return number;
    final index = monthNames.indexWhere((m) => m.toLowerCase() == value.toLowerCase());
    return index < 0 ? null : index + 1;
  }
  static const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  String monthName(int value) => monthNames[value - 1];
  String weekday(int value) => const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][value - 1];
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _StepPill extends StatelessWidget {
  const _StepPill(this.number, this.text);

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: _AuspiciousCalenderState.orange),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 31,
            height: 31,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: _AuspiciousCalenderState.orange, shape: BoxShape.circle),
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 9),
          Text(text, style: const TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w700)),
        ]),
      );
}