// file: lib/screens/course_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';

class CourseDetailsScreen extends StatefulWidget {
  final int idKhoaHoc;
  final String courseName; // Pass the name so we can show it in the AppBar immediately

  const CourseDetailsScreen({
    super.key,
    required this.idKhoaHoc,
    required this.courseName,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final CourseService _courseService = CourseService();
  late Future<KhoaHoc?> _courseDetailsFuture;

  @override
  void initState() {
    super.initState();
    _courseDetailsFuture = _courseService.getCourseById(widget.idKhoaHoc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.courseName, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<KhoaHoc?>(
        future: _courseDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Failed to load course details."));
          }

          final course = snapshot.data!;
          final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Course Header Info
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.tenKhoaHoc, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text("${course.thoiLuong} hours"),
                          const SizedBox(width: 20),
                          const Icon(Icons.payments_outlined, size: 18, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(formatCurrency.format(course.hocPhi), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 30),
                      if (course.moTa != null) ...[
                        const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(course.moTa!, style: const TextStyle(color: Colors.black87, height: 1.5)),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Available Classes List (LopHocs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Available Classes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      if (course.lopHocs == null || course.lopHocs!.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No classes are currently scheduled for this course.", style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: course.lopHocs!.length,
                          itemBuilder: (context, index) {
                            final lop = course.lopHocs![index];
                            final dateFormat = DateFormat('dd/MM/yyyy');

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                title: Text(lop.tenLop, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text("Schedule: ${dateFormat.format(lop.ngayBatDau)} - ${dateFormat.format(lop.ngayKetThuc)}"),
                                    const SizedBox(height: 5),
                                    Text("Seats Left: ${lop.soChoConLai} / ${lop.siSoToiDa}",
                                        style: TextStyle(color: lop.soChoConLai > 0 ? Colors.blue : Colors.red)),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: lop.allowDangKy ? () {
                                    // TODO: Navigate to Registration confirmation
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3C72),
                                    disabledBackgroundColor: Colors.grey[300],
                                  ),
                                  child: const Text("Register", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}