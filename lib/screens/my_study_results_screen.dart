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
  late Future<List<dynamic>> _examResultsFuture;
  late Future<List<dynamic>> _examScheduleFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _studyResultsFuture = _resultsService.getMyStudyResults();
    _examResultsFuture = _resultsService.getMyExamResults();
    _examScheduleFuture = _resultsService.getMyExamSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Kết quả & Lịch thi",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          
          
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Học tập", icon: Icon(Icons.assignment)),
              Tab(text: "Thi cử", icon: Icon(Icons.grade)),
              Tab(text: "Lịch thi", icon: Icon(Icons.calendar_month)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStudyResultsTab(),
            _buildExamResultsTab(),
            _buildExamScheduleTab(),
          ],
        ),
      ),
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
            final diemCC = res['diemChuyenCan'];
            final diemThi = res['diemThi'];
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
                        const Text("Chuyên cần:"),
                        Text(diemCC != null ? diemCC.toString() : "-"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Điểm thi:"),
                        Text(diemThi != null ? diemThi.toString() : "-"),
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

  Widget _buildExamResultsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _examResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text("Bạn chưa có kết quả thi nào."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final res = results[index];
            final className = res['tenLop'] ?? 'Không rõ';
            final diem = res['diem'];
            final ketQua = res['ketQua'] ?? 'Không rõ';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
                subtitle: Text("Điểm thi: ${diem != null ? diem.toString() : "-"}"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ketQua == "Đạt" ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ketQua,
                    style: TextStyle(color: ketQua == "Đạt" ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExamScheduleTab() {
    return FutureBuilder<List<dynamic>>(
      future: _examScheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error}"));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text("Bạn chưa có lịch thi nào."));
        }

        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final res = results[index];
            final className = res['tenLop'] ?? 'Không rõ';
            final roomName = res['tenPhong'] ?? 'Không rõ';
            final dateStr = res['ngayThi'];
            final date = dateStr != null ? DateTime.parse(dateStr) : null;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  
                  child: Icon(Icons.event, color: Colors.white),
                ),
                title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text("Phòng thi: $roomName"),
                    const SizedBox(height: 5),
                    Text("Thời gian: ${date != null ? dateFormat.format(date) : "N/A"}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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
