import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';
import '../services/registration_service.dart';

class ClassDetailsScreen extends StatefulWidget {
  final int idLop;

  const ClassDetailsScreen({super.key, required this.idLop});

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  final ClassService _classService = ClassService();
  final RegistrationService _registrationService = RegistrationService();

  late Future<LopHoc?> _classDetailsFuture;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _classDetailsFuture = _classService.getClassById(widget.idLop);
  }

  void _handleRegistration() async {
    // 1. Show confirmation dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Registration'),
        content: const Text('Do you want to enroll in this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Process Registration
    setState(() => _isRegistering = true);

    bool success = await _registrationService.registerForClass(widget.idLop);

    setState(() => _isRegistering = false);

    // 3. Handle Result
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Return true to refresh the previous list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. The class might be full or already registered.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Class Information", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<LopHoc?>(
        future: _classDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load class details."));
          }

          final lop = snapshot.data!;
          final dateFormat = DateFormat('dd/MM/yyyy');
          final isAvailable = lop.allowDangKy && lop.soChoConLai > 0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lop.tenLop,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                            ),
                            const SizedBox(height: 15),
                            _buildInfoRow(Icons.calendar_today, "Schedule", "${dateFormat.format(lop.ngayBatDau)} - ${dateFormat.format(lop.ngayKetThuc)}"),
                            const Divider(height: 30),
                            _buildInfoRow(Icons.people, "Capacity", "${lop.siSoToiDa} students maximum"),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.how_to_reg, "Enrolled", "${lop.soHocVienDangKy} students"),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              Icons.event_seat,
                              "Seats Left",
                              "${lop.soChoConLai}",
                              valueColor: lop.soChoConLai < 5 ? Colors.red : Colors.green,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Notes Section
                      if (lop.ghiChu != null && lop.ghiChu!.isNotEmpty) ...[
                        const Text("Important Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(lop.ghiChu!, style: TextStyle(color: Colors.brown.shade800)),
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              // Bottom Registration Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -3))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (isAvailable && !_isRegistering) ? _handleRegistration : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3C72),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isRegistering
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                      isAvailable ? "CONFIRM REGISTRATION" : "REGISTRATION CLOSED",
                      style: TextStyle(color: isAvailable ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text("$label: ", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: valueColor ?? Colors.black87),
          ),
        ),
      ],
    );
  }
}