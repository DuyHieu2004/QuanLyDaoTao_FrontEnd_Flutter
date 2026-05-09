import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/instructor_service.dart';

class InstructorScheduleScreen extends StatefulWidget {
  const InstructorScheduleScreen({super.key});

  @override
  State<InstructorScheduleScreen> createState() => _InstructorScheduleScreenState();
}

class _InstructorScheduleScreenState extends State<InstructorScheduleScreen> {
  final InstructorService _instructorService = InstructorService();
  late Future<List<dynamic>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _instructorService.getMySchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Lịch giảng dạy",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          final scheduleList = snapshot.data ?? [];
          if (scheduleList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Bạn chưa được phân công lớp nào.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final dateFormat = DateFormat('dd/MM/yyyy');

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scheduleList.length,
            itemBuilder: (context, index) {
              final assignment = scheduleList[index];
              final className = assignment['tenLop'] ?? 'Không rõ lớp';
              final courseName = assignment['tenKhoaHoc'] ?? 'Không rõ khóa học';
              final startDateStr = assignment['ngayBatDau'];
              final endDateStr = assignment['ngayKetThuc'];
              
              final startDate = startDateStr != null ? DateTime.tryParse(startDateStr) : null;
              final endDate = endDateStr != null ? DateTime.tryParse(endDateStr) : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.class_, color: Color(0xFF1E3C72)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              className,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3C72),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(courseName, style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            "Thời gian: ${startDate != null ? dateFormat.format(startDate) : '-'} đến ${endDate != null ? dateFormat.format(endDate) : '-'}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
