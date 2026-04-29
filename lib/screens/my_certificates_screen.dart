// file: lib/screens/my_certificates_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/certificate_model.dart';
import '../services/certificate_service.dart';

class MyCertificatesScreen extends StatefulWidget {
  final int studentId;

  const MyCertificatesScreen({super.key, required this.studentId});

  @override
  State<MyCertificatesScreen> createState() => _MyCertificatesScreenState();
}

class _MyCertificatesScreenState extends State<MyCertificatesScreen> {
  final CertificateService _certificateService = CertificateService();
  late Future<List<ChungChi>> _certificatesFuture;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  void _loadCertificates() {
    setState(() {
      _certificatesFuture = _certificateService.getMyCertificates(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Certificates", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<ChungChi>>(
        future: _certificatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final certificates = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              return _buildCertificateCard(certificates[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildCertificateCard(ChungChi cert) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle pattern/icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.workspace_premium, size: 150, color: Colors.amber.withOpacity(0.1)),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.workspace_premium, size: 50, color: Colors.amber),
                const SizedBox(height: 15),
                const Text(
                  "CERTIFICATE OF COMPLETION",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF1E3C72),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text("This is to certify that", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                const SizedBox(height: 10),
                Text(
                  cert.hoTenHocVien ?? "Student",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text("has successfully completed the course", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                const SizedBox(height: 10),
                Text(
                  cert.tenKhoaHoc ?? "Unknown Course",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E3C72)),
                  textAlign: TextAlign.center,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(thickness: 1, endIndent: 40, indent: 40),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Date Issued", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          cert.ngayCap != null ? dateFormat.format(cert.ngayCap!) : "N/A",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Credential ID", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          "#${cert.idChungChi.toString().padLeft(6, '0')}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.military_tech_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "No Certificates Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          const Text(
            "Complete a course to earn your first certificate!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}