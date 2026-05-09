// file: lib/screens/class_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm import này
import '../models/class_model.dart';
import '../services/class_service.dart';
import '../blocs/class_bloc/class_bloc.dart';
import '../blocs/class_bloc/class_event.dart';
import '../blocs/class_bloc/class_state.dart';
import 'class_details_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  int? currentStudentId;
  bool isLoadingId = true; // Biến cờ để chờ load ID xong mới vẽ giao diện
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  // Hàm bất đồng bộ để lấy ID từ vùng nhớ
  Future<void> _loadStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // TODO: Sửa lại chữ 'user_id' cho đúng với key bạn đã set lúc gọi hàm Login nhé
    final int? storedId = prefs.getInt('user_id'); 

    setState(() {
      currentStudentId = storedId ?? 1; // Nếu null (lỗi gì đó) thì fallback về 1 để app không crash
      isLoadingId = false; // Load xong rồi, cho phép vẽ giao diện
    });
  }

  @override
  Widget build(BuildContext context) {
    // Trong lúc đang moi ID từ SharedPreferences ra thì hiện vòng xoay mờ mờ
    if (isLoadingId || currentStudentId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      // Khởi tạo BLoC và bắn ngay event fetch data bằng ID vừa lấy được
      create: (context) => ClassBloc(classService: ClassService())
        ..add(FetchAvailableClasses(idHocVien: currentStudentId!)),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Lớp học có sẵn",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1E3C72),
          elevation: 0,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  context.read<ClassBloc>().add(FetchAvailableClasses(idHocVien: currentStudentId!));
                },
              ),
            ),
          ],
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
            context.read<ClassBloc>().add(FetchAvailableClasses(idHocVien: currentStudentId!));
          },
          child: BlocBuilder<ClassBloc, ClassState>(
            builder: (context, state) {
              if (state is ClassLoading || state is ClassInitial) {
                return const Center(child: CircularProgressIndicator());
              } 
              
              else if (state is ClassError) {
                return _buildErrorState(context, state.message);
              } 
              
              else if (state is ClassLoaded) {
                if (state.classes.isEmpty) {
                  return _buildEmptyState();
                }

                // Lọc danh sách theo từ khóa tìm kiếm
                final filteredClasses = state.classes.where((lop) {
                  final className = lop.tenLop.toLowerCase();
                  final searchLower = _searchQuery.toLowerCase();
                  return className.contains(searchLower);
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
                          hintText: "Tìm kiếm tên lớp...",
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

                    // Danh sách lớp
                    Expanded(
                      child: filteredClasses.isEmpty
                          ? const Center(child: Text("Không tìm thấy kết quả nào."))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              itemCount: filteredClasses.length,
                              itemBuilder: (context, index) {
                                return _buildClassCard(context, filteredClasses[index]);
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

  Widget _buildClassCard(BuildContext context, LopHoc lop) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    bool isOpen = lop.allowDangKy;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lop.tenLop,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3C72),
                    ),
                  ),
                ),
                _buildStatusBadge(isOpen),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.calendar_month_outlined,
                  "Lịch học",
                  "${dateFormat.format(lop.ngayBatDau)} - ${dateFormat.format(lop.ngayKetThuc)}",
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.people_outline,
                  "Số lượng",
                  "${lop.soHocVienDangKy} / ${lop.siSoToiDa} học viên",
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.event_seat_outlined,
                  "Còn trống",
                  "Còn ${lop.soChoConLai} chỗ",
                  valueColor: lop.soChoConLai < 5 ? Colors.red : Colors.blue,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsScreen(idLop: lop.idLop),
                    ),
                  );

                  if (result == true && context.mounted) {
                    context.read<ClassBloc>().add(FetchAvailableClasses(idHocVien: currentStudentId!));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "XEM CHI TIẾT",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? "MỞ" : "ĐÓNG",
        style: TextStyle(
          color: isOpen ? Colors.green[700] : Colors.red[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text("$label: ", style: TextStyle(color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
          const SizedBox(height: 16),
          const Text("Bạn đã đăng ký hết các lớp hiện có!"),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text("Rất tiếc! Đã có lỗi xảy ra."),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<ClassBloc>().add(FetchAvailableClasses(idHocVien: currentStudentId!));
            },
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }
}