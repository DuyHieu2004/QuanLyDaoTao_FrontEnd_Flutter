import 'package:flutter/material.dart';
import '../services/instructor_service.dart';

class RegisterInstructorScreen extends StatefulWidget {
  const RegisterInstructorScreen({super.key});

  @override
  State<RegisterInstructorScreen> createState() => _RegisterInstructorScreenState();
}

class _RegisterInstructorScreenState extends State<RegisterInstructorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _chuyenMonController = TextEditingController();
  final _dienThoaiController = TextEditingController();
  final _emailController = TextEditingController();
  final _phiController = TextEditingController();

  final InstructorService _instructorService = InstructorService();
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      double phi = double.tryParse(_phiController.text) ?? 0;

      bool success = await _instructorService.createInstructor(
        _hoTenController.text.trim(),
        _chuyenMonController.text.trim(),
        _dienThoaiController.text.trim(),
        _emailController.text.trim(),
        phi,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Đăng ký thành công'),
            content: const Text(
              'Yêu cầu đăng ký giảng viên của bạn đã được gửi. Vui lòng chờ admin xét duyệt.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close screen
                },
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _chuyenMonController.dispose();
    _dienThoaiController.dispose();
    _emailController.dispose();
    _phiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Đăng ký giảng viên',
          style: TextStyle(color: Colors.black),
        ),
        
        
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Thông tin đăng ký',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3C72),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _hoTenController,
                      label: 'Họ và tên',
                      icon: Icons.person,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vui lòng nhập họ và tên'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _chuyenMonController,
                      label: 'Chuyên môn',
                      icon: Icons.work,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vui lòng nhập chuyên môn'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _dienThoaiController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vui lòng nhập số điện thoại'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email';
                        }
                        if (!value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _phiController,
                      label: 'Mức phí giảng dạy dự kiến (VNĐ)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'GỬI YÊU CẦU ĐĂNG KÝ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E3C72)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E3C72), width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
