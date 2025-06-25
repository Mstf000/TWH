// data/services/ai_summary_parser.dart

class ParsedSection {
  final String title;
  final List<String> bullets;
  final String paragraph;

  ParsedSection({
    required this.title,
    this.bullets = const [],
    this.paragraph = '',
  });
}

class AISummaryParser {
  static List<ParsedSection> parseSummary(String summary) {
    final List<ParsedSection> sections = [];

    final sectionRegex =
        RegExp(r'\*\*(\d+\..*?)\*\*(.*?)((?=\*\*\d+)|$)', dotAll: true);
    final matches = sectionRegex.allMatches(summary);

    for (final match in matches) {
      final title = match.group(1)?.trim() ?? '';
      final body = match.group(2)?.trim() ?? '';

      final bulletRegex = RegExp(r'\*\s+(.*)');
      final bullets =
          bulletRegex.allMatches(body).map((m) => m.group(1)!.trim()).toList();

      final nonBullets = body
          .split('\n')
          .where((line) => !line.trim().startsWith('*'))
          .join(' ')
          .trim();

      sections.add(
        ParsedSection(
          title: title,
          bullets: bullets,
          paragraph: nonBullets,
        ),
      );
    }

    return sections;
  }
}
