// file: lib/screens/class_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/class_service.dart';
import '../models/class_model.dart';
import 'class_details_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final ClassService _classService = ClassService();
  late Future<List<LopHoc>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // Method to (re)load the data
  void _loadClasses() {
    setState(() {
      _classesFuture = _classService.getAllClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Available Classes",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3C72),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadClasses,
          ),
        ],
      ),
      // RefreshIndicator allows you to "pull down" to reload the list
      body: RefreshIndicator(
        onRefresh: () async => _loadClasses(),
        child: FutureBuilder<List<LopHoc>>(
          future: _classesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final classes = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                return _buildClassCard(classes[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassCard(LopHoc lop) {
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
          // Header of the card
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

          // Details section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(Icons.calendar_month_outlined, "Schedule",
                    "${dateFormat.format(lop.ngayBatDau)} - ${dateFormat.format(lop.ngayKetThuc)}"),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.people_outline, "Enrollment",
                    "${lop.soHocVienDangKy} / ${lop.siSoToiDa} Students"),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.event_seat_outlined, "Available",
                    "${lop.soChoConLai} seats left",
                    valueColor: lop.soChoConLai < 5 ? Colors.red : Colors.blue),
              ],
            ),
          ),

          // Action Button - UPDATED HERE
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to details screen and wait for result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsScreen(idLop: lop.idLop),
                    ),
                  );

                  // If the user registered successfully, refresh this list to update seat counts
                  if (result == true) {
                    _loadClasses();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "VIEW DETAILS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
        isOpen ? "OPEN" : "CLOSED",
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
          Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No classes available at the moment."),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text("Oops! Something went wrong."),
            Text(error, style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loadClasses, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}