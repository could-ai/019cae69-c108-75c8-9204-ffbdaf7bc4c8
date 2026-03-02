import 'dart:math';

class DailyReportItem {
  final DateTime date;
  final Map<int, int> countsByAttempt; // Key: Attempt Count, Value: Number of Cases

  DailyReportItem({required this.date, required this.countsByAttempt});
}

class ReportService {
  // In a real app, you would inject the Supabase client here
  // final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<DailyReportItem>> getCallReportData() async {
    // SIMULATION MODE:
    // Since we might not have a live Supabase connection in this demo environment,
    // we will return the mock data that matches the SQL we just executed.
    // 
    // TO ENABLE REAL DATA:
    // Uncomment the Supabase code block below and remove the mock data block.

    /*
    // REAL SUPABASE IMPLEMENTATION:
    final response = await _supabase
        .from('call_records')
        .select('created_at, attempt_count')
        .neq('status', 'connected') // Filter out connected calls
        .order('created_at');

    // Process the raw data into our report format
    return _processData(response);
    */

    // MOCK DATA IMPLEMENTATION (Matching the SQL inserted data):
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    final List<Map<String, dynamic>> mockRawData = [
      // Today
      {'created_at': now.toIso8601String(), 'attempt_count': 0},
      {'created_at': now.toIso8601String(), 'attempt_count': 0},
      {'created_at': now.toIso8601String(), 'attempt_count': 1},
      {'created_at': now.toIso8601String(), 'attempt_count': 3},
      
      // Yesterday
      {'created_at': yesterday.toIso8601String(), 'attempt_count': 0},
      {'created_at': yesterday.toIso8601String(), 'attempt_count': 0},
      {'created_at': yesterday.toIso8601String(), 'attempt_count': 0},
      {'created_at': yesterday.toIso8601String(), 'attempt_count': 2},
      {'created_at': yesterday.toIso8601String(), 'attempt_count': 2},
      
      // 2 Days Ago
      {'created_at': twoDaysAgo.toIso8601String(), 'attempt_count': 1},
      {'created_at': twoDaysAgo.toIso8601String(), 'attempt_count': 1},
      {'created_at': twoDaysAgo.toIso8601String(), 'attempt_count': 4},
      {'created_at': twoDaysAgo.toIso8601String(), 'attempt_count': 0},
    ];

    return _processData(mockRawData);
  }

  List<DailyReportItem> _processData(List<dynamic> rawData) {
    final Map<String, Map<int, int>> groupedData = {};

    for (var record in rawData) {
      final dateStr = DateTime.parse(record['created_at']).toString().substring(0, 10); // YYYY-MM-DD
      final attemptCount = record['attempt_count'] as int;

      if (!groupedData.containsKey(dateStr)) {
        groupedData[dateStr] = {};
      }

      groupedData[dateStr]![attemptCount] = (groupedData[dateStr]![attemptCount] ?? 0) + 1;
    }

    // Convert to List<DailyReportItem>
    final List<DailyReportItem> reportItems = groupedData.entries.map((entry) {
      return DailyReportItem(
        date: DateTime.parse(entry.key),
        countsByAttempt: entry.value,
      );
    }).toList();

    // Sort by date descending
    reportItems.sort((a, b) => b.date.compareTo(a.date));

    return reportItems;
  }
}
