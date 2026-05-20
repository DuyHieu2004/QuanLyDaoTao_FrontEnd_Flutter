// file: lib/screens/my_registrations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../services/registration_service.dart';
import '../blocs/registration_bloc/registration_bloc.dart';
import '../blocs/registration_bloc/registration_event.dart';
import '../blocs/registration_bloc/registration_state.dart';
import 'payment_details_screen.dart'; 

class MyRegistrationsScreen extends StatefulWidget {
  const MyRegistrationsScreen({super.key});

  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Khởi tạo Bloc và bắn ngay event Fetch dữ liệu khi vừa vào màn hình
      create: (context) => RegistrationBloc(registrationService: RegistrationService())
        ..add(FetchMyRegistrations()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Đăng ký của tôi",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          
          
          elevation: 0,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) {
        return RefreshIndicator(
          onRefresh: () async {
            // Kéo xuống để refresh -> Bắn lại event
            context.read<RegistrationBloc>().add(FetchMyRegistrations());
          },
          child: BlocBuilder<RegistrationBloc, RegistrationState>(
            builder: (context, state) {
              if (state is RegistrationLoading || state is RegistrationInitial) {
                return const Center(child: CircularProgressIndicator());
              } 
              
              else if (state is RegistrationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<RegistrationBloc>().add(FetchMyRegistrations()),
                        child: const Text("Thử lại"),
                      )
                    ],
                  ),
                );
              } 
              
              else if (state is RegistrationLoaded) {
                if (state.registrations.isEmpty) {
                  return ListView(
                    // Dùng ListView để RefreshIndicator vẫn hoạt động được khi trống
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("Bạn chưa đăng ký lớp học nào.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Lọc dữ liệu dựa trên từ khóa tìm kiếm
                final filteredRegistrations = state.registrations.where((reg) {
                  final className = (reg['lopHocInfo']?['tenLop'] ?? '').toString().toLowerCase();
                  final courseName = (reg['khoaHocInfo']?['tenKhoaHoc'] ?? '').toString().toLowerCase();
                  final searchLower = _searchQuery.toLowerCase();
                  return className.contains(searchLower) || courseName.contains(searchLower);
                }).toList();

                return Column(
                  children: [
                    // Thanh tìm kiếm
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm lớp học, khóa học...",
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3C72)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    
                    // Danh sách
                    Expanded(
                      child: filteredRegistrations.isEmpty
                          ? const Center(child: Text("Không tìm thấy kết quả nào."))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              itemCount: filteredRegistrations.length,
                              itemBuilder: (context, index) {
                                return _buildRegistrationCard(context, filteredRegistrations[index]);
                              },
                            ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      }
    );
  }

  Widget _buildRegistrationCard(BuildContext context, dynamic reg) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Bóc tách dữ liệu từ JSON map của API trả về
    final idDangKy = reg['idDangKy'] ?? 0;
    final className = reg['lopHocInfo']?['tenLop'] ?? 'Không rõ lớp học';
    final courseName = reg['khoaHocInfo']?['tenKhoaHoc'] ?? 'Không rõ khóa học';
    final fee = (reg['khoaHocInfo']?['hocPhi'] ?? 0).toDouble();
    final status = reg['trangThaiThanhToan'] ?? 'Chưa thanh toán';
    final isPaid = status.toString().toLowerCase() == 'đã thanh toán' ||
                   status.toString().toLowerCase() == 'paid' ||
                   status.toString().toLowerCase() == 'đã';
    final regDate = reg['ngayDangKy'] != null ? DateTime.parse(reg['ngayDangKy']) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ID: #$idDangKy",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPaid ? "ĐÃ THANH TOÁN" : "CHƯA THANH TOÁN",
                    style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              className,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3C72),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              courseName,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Học phí:", style: TextStyle(color: Colors.grey.shade600)),
                Text(
                  formatCurrency.format(fee),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (regDate != null) ...[
              const SizedBox(height: 5),
              Text(
                "Đăng ký: ${dateFormat.format(regDate)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],

            // HIỂN THỊ NÚT THANH TOÁN NẾU CHƯA ĐÓNG TIỀN
            if (!isPaid) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (idDangKy <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không thể xác định mã đăng ký. Vui lòng tải lại trang.')),
                      );
                      return;
                    }
                    // Chuyển sang màn hình thanh toán
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentDetailsScreen(idDangKy: idDangKy),
                      ),
                    );
                    
                    // Khi thanh toán xong quay về, gọi BLoC load lại danh sách để cập nhật trạng thái
                    if (context.mounted) {
                      context.read<RegistrationBloc>().add(FetchMyRegistrations());
                    }
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    "THANH TOÁN NGAY",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}