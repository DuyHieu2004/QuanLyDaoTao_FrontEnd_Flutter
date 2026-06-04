import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/results_service.dart';

class MyStudyResultsScreen extends StatefulWidget {
  const MyStudyResultsScreen({super.key});

  @override
  State<MyStudyResultsScreen> createState() => _MyStudyResultsScreenState();
}

class _MyStudyResultsScreenState extends State<MyStudyResultsScreen> {
  final ResultsService _resultsService = ResultsService();

  late Future<List<dynamic>> _studyResultsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _studyResultsFuture = _resultsService.getMyStudyResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Kết quả học tập",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildStudyResultsTab(),
    );
  }

  Widget _buildStudyResultsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _studyResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text("Bạn chưa có kết quả học tập nào."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final res = results[index];
            final className = res['className'] ?? 'Không rõ';
            final courseName = res['courseeName'] ?? 'Không rõ';
            final diemLT = res['diemLyThuyet'];
            final diemTH = res['diemThucHanh'];
            final diemTB = res['diemTrungBinh'];
            final ketLuan = res['ketLuan'] ?? 'Chưa có';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      className,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                    ),
                    Text(courseName, style: TextStyle(color: Colors.grey.shade700)),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Lý thuyết:"),
                        Text(diemLT != null ? diemLT.toString() : "-"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Thực hành:"),
                        Text(diemTH != null ? diemTH.toString() : "-"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Trung bình:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(diemTB != null ? diemTB.toStringAsFixed(1) : "-", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Kết luận:"),
                        Text(
                          ketLuan,
                          style: TextStyle(
                            color: ketLuan.toString().toLowerCase().contains("không") ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
