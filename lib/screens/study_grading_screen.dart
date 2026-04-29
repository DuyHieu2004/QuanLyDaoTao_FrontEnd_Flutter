// file: lib/screens/study_grading_screen.dart

import 'package:flutter/material.dart';
import '../models/study_result_model.dart';
import '../services/study_result_service.dart';

class StudyGradingScreen extends StatefulWidget {
  final int classId;
  final String className;

  const StudyGradingScreen({super.key, required this.classId, required this.className});

  @override
  State<StudyGradingScreen> createState() => _StudyGradingScreenState();
}

class _StudyGradingScreenState extends State<StudyGradingScreen> {
  final StudyResultService _service = StudyResultService();

  late Future<List<StudyResult>> _resultsFuture;
  late Future<ClassStatistics?> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _resultsFuture = _service.getResultsByClass(widget.classId);
      _statsFuture = _service.getClassStatistics(widget.classId);
    });
  }

  void _showGradingDialog(StudyResult result) {
    final attController = TextEditingController(text: result.diemChuyenCan > 0 ? result.diemChuyenCan.toString() : '');
    final examController = TextEditingController(text: result.diemThi > 0 ? result.diemThi.toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Grade: ${result.hocVienName ?? "Student"}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: attController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Attendance Score (Chuyên cần)', prefixIcon: Icon(Icons.co_present)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: examController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Exam Score (Điểm thi)', prefixIcon: Icon(Icons.quiz)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final double? attScore = double.tryParse(attController.text.trim());
                final double? examScore = double.tryParse(examController.text.trim());

                if (attScore == null || examScore == null || attScore < 0 || examScore < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid positive numbers.')));
                  return;
                }

                Navigator.pop(context); // Close dialog

                bool success = await _service.updateResult(result.idKetQua, attScore, examScore);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scores updated!'), backgroundColor: Colors.green));
                  _loadData(); // Refresh the list and stats!
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed.'), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.className, style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
      ),
      body: Column(
        children: [
          // Top Section: Statistics Card
          FutureBuilder<ClassStatistics?>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
              final stats = snapshot.data!;

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E3C72), Color(0xFF2A5298)]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Text("Class Performance", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Avg Score", stats.averageScore.toStringAsFixed(1)),
                        _buildStatItem("Pass Rate", "${stats.passRate.toStringAsFixed(1)}%"),
                        _buildStatItem("Passed", "${stats.passed}/${stats.totalStudents}"),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Section: Student List
          Expanded(
            child: FutureBuilder<List<StudyResult>>(
              future: _resultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No students or results found."));
                }

                final results = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final res = results[index];
                    final isPassed = res.ketLuan?.toLowerCase() == 'đạt' || res.ketLuan?.toLowerCase() == 'passed';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => _showGradingDialog(res),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(res.hocVienName ?? "Student ID: ${res.idDangKy}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Attendance: ${res.diemChuyenCan} | Exam: ${res.diemThi}", style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(res.ketLuan ?? "Pending", style: TextStyle(color: isPassed ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                          child: Text(
                            res.diemTrungBinh.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3C72), fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}