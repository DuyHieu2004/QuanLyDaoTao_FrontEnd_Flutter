// file: lib/screens/grading_screen.dart

import 'package:flutter/material.dart';
import '../models/exam_result_model.dart';
import '../services/exam_result_service.dart';

class GradingScreen extends StatefulWidget {
  final int scheduleId; // The ID of the exam schedule (LichThi)

  const GradingScreen({super.key, required this.scheduleId});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  final ExamResultService _examResultService = ExamResultService();
  late Future<List<KetQuaThi>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  void _loadResults() {
    setState(() {
      _resultsFuture = _examResultService.getResultsBySchedule(
        widget.scheduleId,
      );
    });
  }

  // Show a dialog for the teacher to input or edit the score
  void _showGradingDialog(KetQuaThi studentResult) {
    final TextEditingController scoreController = TextEditingController(
      // If the score is > 0, show current score, otherwise leave blank for new entry
      text: studentResult.diem > 0 ? studentResult.diem.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chấm điểm: ${studentResult.hoTenHocVien ?? "Học viên"}'),
          content: TextField(
            controller: scoreController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Điểm số (Diem)',
              border: OutlineInputBorder(),
              hintText: 'ví dụ: 8.5',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final double? newScore = double.tryParse(
                  scoreController.text.trim(),
                );
                if (newScore == null || newScore < 0 || newScore > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập điểm hợp lệ từ 0 đến 10.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context); // Close dialog

                bool success;
                // If idKetQuaThi is 0, it means it hasn't been created in the DB yet -> POST
                // If it has an ID > 0, it exists -> PUT
                if (studentResult.idKetQuaThi == 0) {
                  success = await _examResultService.createResult(
                    widget.scheduleId,
                    studentResult.idHocVien,
                    newScore,
                  );
                } else {
                  success = await _examResultService.updateResult(
                    studentResult.idKetQuaThi,
                    newScore,
                  );
                }

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Điểm đã được lưu thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadResults(); // Refresh the list to show new scores
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lưu điểm thất bại.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Chấm thi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        
        
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadResults(),
        child: FutureBuilder<List<KetQuaThi>>(
          future: _resultsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Không tìm thấy học viên cho lịch thi này."),
              );
            }

            final results = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final res = results[index];
                // Determine color based on pass/fail logic (e.g., >= 5.0 is pass)
                final isPassed = res.diem >= 5.0;
                final hasScore = res.idKetQuaThi > 0 || res.diem > 0;

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
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withOpacity(0.1),
                      child: const Icon(Icons.person, color: Color(0xFF1E3C72)),
                    ),
                    title: Text(
                      res.hoTenHocVien ?? "Học viên không rõ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      hasScore
                          ? "Trạng thái: ${res.ketQua ?? (isPassed ? 'Đạt' : 'Không đạt')}"
                          : "Trạng thái: Chưa chấm",
                      style: TextStyle(
                        color: hasScore
                            ? (isPassed ? Colors.green : Colors.red)
                            : Colors.grey,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasScore ? res.diem.toStringAsFixed(1) : "-",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: hasScore
                                ? const Color(0xFF1E3C72)
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.blue),
                          onPressed: () => _showGradingDialog(res),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
