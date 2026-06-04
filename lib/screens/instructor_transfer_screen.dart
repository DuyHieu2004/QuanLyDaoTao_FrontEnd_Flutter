// file: lib/screens/instructor_transfer_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_transfer_model.dart';
import '../services/class_transfer_service.dart';

class InstructorTransferScreen extends StatefulWidget {
  const InstructorTransferScreen({super.key});

  @override
  State<InstructorTransferScreen> createState() =>
      _InstructorTransferScreenState();
}

class _InstructorTransferScreenState extends State<InstructorTransferScreen> {
  final ClassTransferService _transferService = ClassTransferService();
  late Future<List<ClassTransfer>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  void _loadPendingRequests() {
    setState(() {
      _pendingFuture = _transferService.getPendingTransfers();
    });
  }

  void _handleApprove(ClassTransfer request) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt chuyển lớp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Phê duyệt chuyển lớp cho ${request.hoTenHocVien}?'),
            const SizedBox(height: 15),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú phê duyệt (Tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // In a real app, 'approverName' would come from your decoded JWT token or User Profile
              bool success = await _transferService.approveTransfer(
                request.idChuyenLop,
                "Doan Duy Hieu (Instructor)", // Replace with dynamic instructor name
                noteController.text.trim(),
              );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chuyển lớp đã được phê duyệt!'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadPendingRequests();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phê duyệt thất bại.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Phê duyệt',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReject(int idChuyenLop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối chuyển lớp'),
        content: const Text(
          'Bạn có chắc chắn muốn từ chối yêu cầu chuyển lớp này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await _transferService.rejectTransfer(idChuyenLop);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chuyển lớp bị từ chối.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                _loadPendingRequests();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Từ chối thất bại.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Từ chối yêu cầu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Chuyển giao chờ xử lý",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        
        
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadPendingRequests(),
        child: FutureBuilder<List<ClassTransfer>>(
          future: _pendingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Không có yêu cầu chuyển lớp chờ xử lý.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final requests = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.swap_horiz,
                              color: Color(0xFF1E3C72),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              req.hoTenHocVien ?? "Student",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildTransferRoute(
                          "From:",
                          req.tenLopCu ?? "Lớp học không xác định",
                          Colors.redAccent,
                        ),
                        const SizedBox(height: 8),
                        _buildTransferRoute(
                          "To:",
                          req.tenLopMoi ?? "Lớp học không xác định",
                          Colors.green,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "L\u00fd do: ${req.lyDo ?? 'Kh\u00f4ng c\u00f3 th\u00f4ng tin'}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (req.ngayChuyenLop != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Y\u00eau c\u1ea7u ng\u00e0y: ${dateFormat.format(req.ngayChuyenLop!)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleReject(req.idChuyenLop),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: const Text(
                                  "TỪ CHỐI",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleApprove(req),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text(
                                  "PHÊ DUYỆT",
                                  style: TextStyle(color: Colors.black),
                                ),
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
        ),
      ),
    );
  }

  Widget _buildTransferRoute(String label, String className, Color iconColor) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Icon(Icons.circle, size: 10, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            className,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
