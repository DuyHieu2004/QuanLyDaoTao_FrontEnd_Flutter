import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditProfileScreen({super.key, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  late TextEditingController _hoTenController;
  late TextEditingController _emailController;
  late TextEditingController _dienThoaiController;
  
  // Hoc Vien specific
  late TextEditingController _diaChiController;
  DateTime? _ngaySinh;
  String? _gioiTinh;
  
  // Giang Vien specific
  late TextEditingController _chuyenMonController;

  bool _isLoading = false;
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = widget.initialData['role'] ?? 'Học viên';
    
    _hoTenController = TextEditingController(text: widget.initialData['hoTen'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _dienThoaiController = TextEditingController(text: widget.initialData['dienThoai'] ?? '');
    
    if (_role == 'Giảng viên') {
      _chuyenMonController = TextEditingController(text: widget.initialData['chuyenMon'] ?? '');
    } else {
      _diaChiController = TextEditingController(text: widget.initialData['diaChi'] ?? '');
      _gioiTinh = widget.initialData['gioiTinh'];
      
      final ns = widget.initialData['ngaySinh'];
      if (ns != null) {
        _ngaySinh = DateTime.tryParse(ns);
      }
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _dienThoaiController.dispose();
    if (_role == 'Giảng viên') {
      _chuyenMonController.dispose();
    } else {
      _diaChiController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngaySinh ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _ngaySinh) {
      setState(() {
        _ngaySinh = picked;
      });
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> updateData = {
      "hoTen": _hoTenController.text,
      "email": _emailController.text,
      "dienThoai": _dienThoaiController.text,
    };

    if (_role == 'Giảng viên') {
      updateData['chuyenMon'] = _chuyenMonController.text;
    } else {
      updateData['diaChi'] = _diaChiController.text;
      updateData['gioiTinh'] = _gioiTinh;
      if (_ngaySinh != null) {
        updateData['ngaySinh'] = _ngaySinh!.toIso8601String();
      }
    }

    bool success = await _authService.updateMyProfile(updateData);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Return true to refresh profile screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật hồ sơ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        
        
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_hoTenController, 'Họ và tên', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(_dienThoaiController, 'Điện thoại', Icons.phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  
                  if (_role == 'Giảng viên') ...[
                    _buildTextField(_chuyenMonController, 'Chuyên môn', Icons.work),
                  ] else ...[
                    // Hoc Vien fields
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Ngày sinh',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(_ngaySinh != null ? DateFormat('dd/MM/yyyy').format(_ngaySinh!) : 'Chọn ngày'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gioiTinh,
                            decoration: const InputDecoration(
                              labelText: 'Giới tính',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.people),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                              DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                              DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                            ],
                            onChanged: (val) {
                              setState(() { _gioiTinh = val; });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_diaChiController, 'Địa chỉ', Icons.location_on),
                  ],
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('LƯU THAY ĐỔI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }
}
