import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';

class ReceiptScreen extends StatelessWidget {
  final ThanhToanModel payment;

  const ReceiptScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Hóa đơn thanh toán', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12, style: BorderStyle.solid, width: 2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 60),
                      const SizedBox(height: 10),
                      const Text('TRUNG TÂM TIN HỌC PYTECH', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 5),
                      const Text('Biên lai thanh toán học phí', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 15),
                      Text('SỐ TIỀN THANH TOÁN', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text(
                        formatCurrency.format(payment.soTien),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                      ),
                    ],
                  ),
                ),
                
                // Body
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildDetailRow('Mã đăng ký', '#${payment.idDangKy}'),
                      _buildDetailRow('Ngày thanh toán', payment.ngayThanhToan != null ? DateFormat('dd/MM/yyyy HH:mm').format(payment.ngayThanhToan!) : 'N/A'),
                      _buildDetailRow('Hình thức', payment.hinhThucThanhToan ?? 'N/A'),
                      _buildDetailRow('Trạng thái', 'Đã thanh toán', valueColor: Colors.green),
                      const SizedBox(height: 20),
                      const Text(
                        '----------------------------------',
                        style: TextStyle(color: Colors.grey, letterSpacing: 2),
                      ),
                      const SizedBox(height: 20),
                      const Text('Cảm ơn bạn đã tin tưởng và đăng ký khóa học tại PyTech.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                
                // Footer Barcode mockup
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(20, (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: index % 2 == 0 ? 3 : 6,
                          height: 40,
                          color: Colors.black87,
                        )),
                      ),
                      const SizedBox(height: 10),
                      Text(payment.idDangKy.toString().padLeft(12, '0'), style: const TextStyle(letterSpacing: 4, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}
