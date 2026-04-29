import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/class_service.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClassService _classService = ClassService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _courseIdController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _allowRegistration = true;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success = await _classService.createClass(
      tenLop: _nameController.text.trim(),
      idKhoaHoc: int.parse(_courseIdController.text),
      ngayBatDau: _startDate,
      ngayKetThuc: _endDate,
      siSoToiDa: int.parse(_maxStudentsController.text),
      allowDangKy: _allowRegistration,
      ghiChu: _noteController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // Return true to trigger a list refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create class.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Class"),
        backgroundColor: const Color(0xFF1E3C72),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(controller: _nameController, label: "Class Name", icon: Icons.class_),
              const SizedBox(height: 15),
              _buildInput(
                  controller: _courseIdController,
                  label: "Course ID",
                  icon: Icons.numbers,
                  isNumber: true
              ),
              const SizedBox(height: 15),
              _buildInput(
                  controller: _maxStudentsController,
                  label: "Max Students",
                  icon: Icons.people,
                  isNumber: true
              ),
              const SizedBox(height: 20),

              // Date Selectors
              Row(
                children: [
                  Expanded(
                    child: _buildDateTile("Start Date", _startDate, () => _selectDate(context, true)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDateTile("End Date", _endDate, () => _selectDate(context, false)),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              SwitchListTile(
                title: const Text("Allow Registration"),
                subtitle: const Text("Can students join this class right now?"),
                value: _allowRegistration,
                activeColor: const Color(0xFF1E3C72),
                onChanged: (val) => setState(() => _allowRegistration = val),
              ),

              _buildInput(controller: _noteController, label: "Notes", icon: Icons.note, maxLines: 3),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72)),
                  child: const Text("CREATE CLASS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (val) => (val == null || val.isEmpty) ? "Required field" : null,
    );
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 5),
            Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}