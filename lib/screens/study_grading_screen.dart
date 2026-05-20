// file: lib/screens/study_grading_screen.dart

import 'package:flutter/material.dart';
import '../models/study_result_model.dart';
import '../services/study_result_service.dart';

class StudyGradingScreen extends StatefulWidget {
  final int classId;
  final String className;

  const StudyGradingScreen({
    super.key,
    required this.classId,
    required this.className,
  });

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.className,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        
        
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Top Section: Statistics Card
          FutureBuilder<ClassStatistics?>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null)
                return const SizedBox.shrink();
              final stats = snapshot.data!;

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Hiệu suất lớp",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          "Điểm TB",
                          stats.averageScore.toStringAsFixed(1),
                        ),
                        _buildStatItem(
                          "Tỷ lệ đạt",
                          "${stats.passRate.toStringAsFixed(1)}%",
                        ),
                        _buildStatItem(
                          "Đạt",
                          "${stats.passed}/${stats.totalStudents}",
                        ),
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
                  return const Center(
                    child: Text("Không tìm thấy học viên hoặc kết quả."),
                  );
                }

                final results = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final res = results[index];
                    final isPassed =
                        res.ketLuan?.toLowerCase() == 'đạt' ||
                        res.ketLuan?.toLowerCase() == 'passed';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          res.hocVienName ?? "Mã học viên: ${res.idDangKy}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Chuyên cần: ${res.diemChuyenCan} | Thi: ${res.diemThi}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              res.ketLuan ?? "Chưa có",
                              style: TextStyle(
                                color: isPassed ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            res.diemTrungBinh.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3C72),
                              fontSize: 16,
                            ),
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
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
