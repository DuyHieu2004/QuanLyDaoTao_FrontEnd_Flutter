// file: lib/screens/payment_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final int idDangKy;

  const PaymentDetailsScreen({super.key, required this.idDangKy});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<ThanhToanModel?> _paymentFuture;

  String _selectedMethod = 'Chuyển khoản (Bank Transfer)';
  final TextEditingController _noteController = TextEditingController();
  bool _isProcessing = false;

  final List<String> _paymentMethods = [
    'Chuyển khoản (Bank Transfer)',
    'Tiền mặt (Cash)',
    'Ví MoMo',
    'VNPay'
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentInfo();
  }

  void _loadPaymentInfo() {
    setState(() {
      _paymentFuture = _paymentService.getPaymentInfo(widget.idDangKy);
    });
  }

  void _handleCheckout() async {
    setState(() => _isProcessing = true);

    bool success = await _paymentService.confirmPayment(
        widget.idDangKy,
        _selectedMethod,
        _noteController.text.trim()
    );

    setState(() => _isProcessing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment confirmed successfully!'), backgroundColor: Colors.green)
      );
      _loadPaymentInfo(); // Reload to show the 'Paid' UI
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Payment Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<ThanhToanModel?>(
        future: _paymentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No payment invoice found for this registration."));
          }

          final payment = snapshot.data!;
          final isPaid = payment.trangThaiThanhToan?.toLowerCase() == 'đã thanh toán' || payment.trangThaiThanhToan?.toLowerCase() == 'paid';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Invoice Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("INVOICE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isPaid ? "PAID" : "PENDING",
                              style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 30),
                      _buildInvoiceRow("Registration ID", "#${payment.idDangKy}"),
                      const SizedBox(height: 10),
                      _buildInvoiceRow("Date Created", payment.ngayTao != null ? DateFormat('dd/MM/yyyy HH:mm').format(payment.ngayTao!) : "N/A"),
                      const SizedBox(height: 10),
                      if (isPaid && payment.ngayThanhToan != null) ...[
                        _buildInvoiceRow("Paid On", DateFormat('dd/MM/yyyy HH:mm').format(payment.ngayThanhToan!)),
                        const SizedBox(height: 10),
                        _buildInvoiceRow("Method", payment.hinhThucThanhToan ?? "N/A"),
                      ],
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                              formatCurrency.format(payment.soTien),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. Checkout Section (Only show if NOT paid)
                if (!isPaid) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Select Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMethod,
                        isExpanded: true,
                        items: _paymentMethods.map((String method) {
                          return DropdownMenuItem<String>(value: method, child: Text(method));
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) setState(() => _selectedMethod = newValue);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: "Notes (Optional)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3C72),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("CONFIRM & PAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ] else ...[
                  // If Paid, maybe show a button to request refund based on your endpoints
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // TODO: Call _paymentService.requestRefund(widget.idDangKy) with confirmation
                      },
                      icon: const Icon(Icons.refresh, color: Colors.red),
                      label: const Text("Request Refund", style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}