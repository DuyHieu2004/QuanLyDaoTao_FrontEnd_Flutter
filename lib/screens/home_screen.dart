// file: lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:khoa_luan_cu_nhan/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORTANT: Added this import
import '../services/auth_service.dart';
import 'grading_screen.dart';
import 'instructor_transfer_screen.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'class_list_screen.dart';
import 'course_list_screen.dart';
import 'my_certificates_screen.dart';
import 'study_grading_screen.dart';
import 'my_registrations_screen.dart';
import 'register_instructor_screen.dart';
import 'my_study_results_screen.dart';
import 'instructor_schedule_screen.dart';
import 'instructor_remuneration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  bool isTeacher = false;
  bool isLoadingRole = true; // Added loading state while checking permissions

  @override
  void initState() {
    super.initState();
    _checkUserPermissions(); // Check permissions as soon as screen loads
  }

  // --- NEW PERMISSION LOGIC ---
  Future<void> _checkUserPermissions() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the role from memory. Default to 2 (HocVien) if something goes wrong.
    final int roleId = prefs.getInt('role_id') ?? 2;

    setState(() {
      // Based on your database: ID_VAI_TRO 3 is GiangVien
      isTeacher = (roleId == 3);
      isLoadingRole = false;
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
    // Show a loading spinner while we figure out if they are a teacher or student
    if (isLoadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          isTeacher ? const InstructorScheduleScreen() : const ClassListScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3C72),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(isTeacher ? Icons.assignment_ind : Icons.class_outlined),
            label: isTeacher ? 'Dạy học' : 'Học tập',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 150,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1E3C72),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              isTeacher
                  ? 'Bảng điều khiển giảng viên'
                  : 'Bảng điều khiển học viên',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                ),
              ),
            ),
          ),
          actions: [
            // THE DEVELOPER TOGGLE BUTTON HAS BEEN PERMANENTLY REMOVED FROM HERE
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hành động nhanh",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Show the correct grid based on their real role
                isTeacher ? _buildTeacherGrid() : _buildStudentGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- FEATURES FOR STUDENTS ---
  Widget _buildStudentGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildMenuCard('Danh mục khóa học', Icons.search, Colors.blue, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseListScreen()),
          );
        }),
        _buildMenuCard('Lớp học có sẵn', Icons.class_, Colors.indigo, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClassListScreen()),
          );
        }),
        _buildMenuCard('Đăng ký của tôi', Icons.how_to_reg, Colors.orange, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyRegistrationsScreen()),
          );
        }),
        _buildMenuCard(
          'Học phí/Thanh toán',
          Icons.account_balance_wallet,
          Colors.teal,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyRegistrationsScreen()),
            );
          },
        ),
        _buildMenuCard('Kết quả học tập', Icons.auto_graph, Colors.green, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyStudyResultsScreen()),
          );
        }),
        _buildMenuCard('Chứng chỉ', Icons.workspace_premium, Colors.amber, () {
          // Hardcoding studentId: 1 for development testing (update later based on token)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyCertificatesScreen(studentId: 1),
            ),
          );
        }),
      ],
    );
  }

  // --- FEATURES FOR TEACHERS ---
  Widget _buildTeacherGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildMenuCard(
          'Lớp học giảng dạy',
          Icons.groups_outlined,
          Colors.indigo,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InstructorScheduleScreen()),
            );
          },
        ),
        _buildMenuCard(
          'Danh sách học viên',
          Icons.people_alt,
          Colors.teal,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StudyGradingScreen(
                  classId: 1,
                  className: "Test Class (ID: 1)",
                ),
              ),
            );
          },
        ),
        _buildMenuCard(
          'Chi phí giảng dạy',
          Icons.payments_outlined,
          Colors.brown,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InstructorRemunerationScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }


}
