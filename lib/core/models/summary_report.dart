class SummaryReport {
  final String name;
  final String email;
  final String aiSummary; // full AI text with both languages
  final DateTime date;

  SummaryReport({
    required this.name,
    required this.email,
    required this.aiSummary,
    required this.date,
  });
}
