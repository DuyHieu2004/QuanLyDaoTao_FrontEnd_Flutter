// file: lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'package:intl/intl.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = _authService.getMyProfile();
    });
  }

  void _handleLogout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất khỏi hệ thống không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Cho phép hình nền gốc hiển thị
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải thông tin: ${snapshot.error}"));
          }
          
          final userInfo = snapshot.data;
          if (userInfo == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Không tìm thấy dữ liệu hồ sơ cá nhân trên hệ thống."),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Đăng xuất ngay"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  )
                ],
              ),
            );
          }

          final role = userInfo['role'] ?? 'Học viên';

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(userInfo),
                const SizedBox(height: 20),
                _buildInfoCard(userInfo, role),
                const SizedBox(height: 20),
                _buildSettingsCard(userInfo),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // Phần Avatar và Tên (Header)
  Widget _buildHeader(Map<String, dynamic> userInfo) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 30, top: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, size: 50, color: Color(0xFF1E3C72)),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            userInfo["hoTen"] ?? "Chưa cập nhật",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            userInfo["email"] ?? "Chưa cập nhật",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              userInfo["role"] ?? "Unknown",
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  // Thẻ chứa các thông tin cá nhân
  Widget _buildInfoCard(Map<String, dynamic> userInfo, String role) {
    final isGiangVien = role == 'Giảng viên';
    
    String? formattedDate;
    if (userInfo["ngaySinh"] != null) {
      final date = DateTime.tryParse(userInfo["ngaySinh"]);
      if (date != null) {
        formattedDate = DateFormat('dd/MM/yyyy').format(date);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Thông tin chung",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3C72),
                ),
              ),
              const Divider(height: 24),
              if (isGiangVien) ...[
                _buildInfoRow(Icons.badge_outlined, "Mã giảng viên", userInfo["idGiangVien"]?.toString()),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.work_outline, "Chuyên môn", userInfo["chuyenMon"]),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.phone_outlined, "Điện thoại", userInfo["dienThoai"]),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.email_outlined, "Email", userInfo["email"]),
              ] else ...[
                _buildInfoRow(Icons.badge_outlined, "Mã học viên", userInfo["idHocVien"]?.toString()),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.cake_outlined, "Ngày sinh", formattedDate),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.transgender_outlined, "Giới tính", userInfo["gioiTinh"]),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.phone_outlined, "Điện thoại", userInfo["dienThoai"]),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.email_outlined, "Email", userInfo["email"]),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_on_outlined, "Địa chỉ", userInfo["diaChi"]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Thẻ chứa các cài đặt/tùy chọn
  Widget _buildSettingsCard(Map<String, dynamic> userInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.blue),
              ),
              title: const Text("Cập nhật hồ sơ"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditProfileScreen(initialData: userInfo)),
                );
                
                // If profile was updated, reload data
                if (result == true) {
                  _loadProfile();
                }
              },
            ),
            const Divider(height: 1, indent: 60),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_reset, color: Colors.orange),
              ),
              title: const Text("Đổi mật khẩu"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              ),
            ),
            const Divider(height: 1, indent: 60),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  // Hàm helper để vẽ từng dòng thông tin cho lẹ
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? "Chưa cập nhật",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}