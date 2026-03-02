import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();
  bool _isLoading = true;
  List<DailyReportItem> _reportData = [];
  List<int> _uniqueAttemptCounts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _reportService.getCallReportData();
      
      // Calculate all unique attempt counts to define our columns
      final Set<int> attempts = {};
      for (var item in data) {
        attempts.addAll(item.countsByAttempt.keys);
      }
      final sortedAttempts = attempts.toList()..sort();

      setState(() {
        _reportData = data;
        _uniqueAttemptCounts = sortedAttempts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Connected Call Report'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportData.isEmpty
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      columns: [
                        const DataColumn(
                          label: Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ..._uniqueAttemptCounts.map((attempt) {
                          String label = attempt == 0
                              ? 'Unattempted (0)'
                              : '$attempt Attempt${attempt > 1 ? 's' : ''}';
                          return DataColumn(
                            label: Text(
                              label,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            numeric: true,
                          );
                        }),
                        const DataColumn(
                          label: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          numeric: true,
                        ),
                      ],
                      rows: _reportData.map((item) {
                        // Calculate row total
                        int rowTotal = item.countsByAttempt.values.fold(0, (sum, count) => sum + count);
                        
                        return DataRow(
                          cells: [
                            DataCell(Text(DateFormat('yyyy-MM-dd').format(item.date))),
                            ..._uniqueAttemptCounts.map((attempt) {
                              final count = item.countsByAttempt[attempt] ?? 0;
                              return DataCell(
                                Text(
                                  count.toString(),
                                  style: count == 0 
                                      ? const TextStyle(color: Colors.grey) 
                                      : const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              );
                            }),
                            DataCell(
                              Text(
                                rowTotal.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
