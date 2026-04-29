// file: lib/screens/my_registrations_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/registration_service.dart';
import 'payment_details_screen.dart'; // Import the payment screen

class MyRegistrationsScreen extends StatefulWidget {
  const MyRegistrationsScreen({super.key});

  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> {
  final RegistrationService _registrationService = RegistrationService();
  late Future<List<dynamic>> _registrationsFuture;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  void _loadRegistrations() {
    setState(() {
      _registrationsFuture = _registrationService.getMyRegistrations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Registrations", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadRegistrations(),
        child: FutureBuilder<List<dynamic>>(
          future: _registrationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("You haven't registered for any classes yet."));
            }

            final registrations = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registrations.length,
              itemBuilder: (context, index) {
                final reg = registrations[index];

                // Safely extract nested data based on your Swagger image
                final idDangKy = reg['idDangKy'] ?? 0;
                final className = reg['lopHocInfo']?['tenLop'] ?? 'Unknown Class';
                final courseName = reg['khoaHocInfo']?['tenKhoaHoc'] ?? 'Unknown Course';
                final fee = (reg['khoaHocInfo']?['hocPhi'] ?? 0).toDouble();
                final status = reg['trangThaiThanhToan'] ?? 'Pending';
                final isPaid = status.toString().toLowerCase() == 'đã thanh toán' || status.toString().toLowerCase() == 'paid';
                final regDate = reg['ngayDangKy'] != null ? DateTime.parse(reg['ngayDangKy']) : null;

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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ID: #$idDangKy", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPaid ? "PAID" : "PENDING",
                                style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        const Divider(height: 20),
                        Text(className, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
                        const SizedBox(height: 5),
                        Text(courseName, style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tuition Fee:", style: TextStyle(color: Colors.grey.shade600)),
                            Text(formatCurrency.format(fee), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                          ],
                        ),
                        if (regDate != null) ...[
                          const SizedBox(height: 5),
                          Text("Registered: ${dateFormat.format(regDate)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],

                        // IF NOT PAID, SHOW PAYMENT BUTTON
                        if (!isPaid) ...[
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Navigate to Payment screen and reload list when returning
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => PaymentDetailsScreen(idDangKy: idDangKy))
                                );
                                _loadRegistrations(); // Refresh status!
                              },
                              icon: const Icon(Icons.payment, color: Colors.white),
                              label: const Text("PAY NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                            ),
                          )
                        ]
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