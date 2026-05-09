import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/instructor_service.dart';

class InstructorRemunerationScreen extends StatefulWidget {
  const InstructorRemunerationScreen({super.key});

  @override
  State<InstructorRemunerationScreen> createState() => _InstructorRemunerationScreenState();
}

class _InstructorRemunerationScreenState extends State<InstructorRemunerationScreen> {
  final InstructorService _instructorService = InstructorService();
  late Future<Map<String, dynamic>?> _remunerationFuture;

  @override
  void initState() {
    super.initState();
    _remunerationFuture = _instructorService.getMyRemuneration();
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Chi phí thù lao",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _remunerationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: Text("Không tìm thấy thông tin thù lao.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          final soLop = data['soLopGiao'] ?? 0;
          final phiGiangDay = (data['phiGiangDay'] ?? 0).toDouble();
          final tongThuLao = (data['tongThiLo'] ?? 0).toDouble();
          final hoTen = data['hoTenGv'] ?? 'N/A';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "TỔNG THÙ LAO DỰ KIẾN",
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatCurrency.format(tongThuLao),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Giảng viên: $hoTen",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.class_, color: Colors.orange),
                          ),
                          title: const Text("Số lớp được giao", style: TextStyle(color: Colors.grey)),
                          trailing: Text(
                            soLop.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.payments, color: Colors.green),
                          ),
                          title: const Text("Phí giảng dạy / lớp", style: TextStyle(color: Colors.grey)),
                          trailing: Text(
                            formatCurrency.format(phiGiangDay),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
