import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/instructor_service.dart';

class InstructorScheduleScreen extends StatefulWidget {
  const InstructorScheduleScreen({super.key});

  @override
  State<InstructorScheduleScreen> createState() =>
      _InstructorScheduleScreenState();
}

class _InstructorScheduleScreenState extends State<InstructorScheduleScreen> {
  final InstructorService _instructorService = InstructorService();
  late Future<List<dynamic>> _scheduleFuture;

  DateTime _currentDate = DateTime.now();
  List<DateTime> _weekDates = [];

  @override
  void initState() {
    super.initState();
    _calculateWeekDates();
    _scheduleFuture = _instructorService.getMyTimetable();
  }

  void _calculateWeekDates() {
    int currentWeekday = _currentDate.weekday; // 1 = Monday, 7 = Sunday
    DateTime startOfWeek = _currentDate.subtract(
      Duration(days: currentWeekday - 1),
    );
    _weekDates = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
  }

  void _changeWeek(int offsetDays) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: offsetDays));
      _calculateWeekDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Lịch giảng dạy",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Điều hướng tuần
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => _changeWeek(-7),
                  tooltip: 'Tuần trước',
                ),
                Text(
                  "Tuần ${dateFormat.format(_weekDates.first)} - ${dateFormat.format(_weekDates.last)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E3C72),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => _changeWeek(7),
                  tooltip: 'Tuần sau',
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Lỗi: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final scheduleList = snapshot.data ?? [];

                // Lọc dữ liệu cho tuần hiện tại
                // scheduleList chứa Ngay, CaHoc, ...
                Map<String, Map<int, List<dynamic>>> weekData = {};
                for (var date in _weekDates) {
                  weekData[dateFormat.format(date)] = {1: [], 2: [], 3: []};
                }

                for (var item in scheduleList) {
                  if (item['ngay'] != null) {
                    try {
                      DateTime itemDate = DateTime.parse(item['ngay']);
                      String dateKey = dateFormat.format(itemDate);
                      if (weekData.containsKey(dateKey)) {
                        int caHoc =
                            item['caHoc'] ?? 1; // 1: Sáng, 2: Chiều, 3: Tối
                        if (caHoc >= 1 && caHoc <= 3) {
                          weekData[dateKey]![caHoc]!.add(item);
                        }
                      }
                    } catch (e) {
                      print("Parse date error: $e");
                    }
                  }
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: const {
                            0: FixedColumnWidth(60.0), // Cột Ca học
                            1: FixedColumnWidth(140.0), // T2
                            2: FixedColumnWidth(140.0), // T3
                            3: FixedColumnWidth(140.0), // T4
                            4: FixedColumnWidth(140.0), // T5
                            5: FixedColumnWidth(140.0), // T6
                            6: FixedColumnWidth(140.0), // T7
                            7: FixedColumnWidth(140.0), // CN
                          },
                          children: [
                            // Header Row
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF0F4F8),
                              ),
                              children: [
                                _buildHeaderCell("Ca học"),
                                _buildHeaderCell(
                                  "Thứ 2\n${dateFormat.format(_weekDates[0])}",
                                ),
                                _buildHeaderCell(
                                  "Thứ 3\n${dateFormat.format(_weekDates[1])}",
                                ),
                                _buildHeaderCell(
                                  "Thứ 4\n${dateFormat.format(_weekDates[2])}",
                                ),
                                _buildHeaderCell(
                                  "Thứ 5\n${dateFormat.format(_weekDates[3])}",
                                ),
                                _buildHeaderCell(
                                  "Thứ 6\n${dateFormat.format(_weekDates[4])}",
                                ),
                                _buildHeaderCell(
                                  "Thứ 7\n${dateFormat.format(_weekDates[5])}",
                                ),
                                _buildHeaderCell(
                                  "Chủ nhật\n${dateFormat.format(_weekDates[6])}",
                                ),
                              ],
                            ),
                            // Sáng Row
                            _buildShiftRow(
                              "Sáng\n(Ca 1)",
                              1,
                              weekData,
                              dateFormat,
                            ),
                            // Chiều Row
                            _buildShiftRow(
                              "Chiều\n(Ca 2)",
                              2,
                              weekData,
                              dateFormat,
                            ),
                            // Tối Row
                            _buildShiftRow(
                              "Tối\n(Ca 3)",
                              3,
                              weekData,
                              dateFormat,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3C72),
          fontSize: 13,
        ),
      ),
    );
  }

  TableRow _buildShiftRow(
    String shiftName,
    int shiftIndex,
    Map<String, Map<int, List<dynamic>>> weekData,
    DateFormat dateFormat,
  ) {
    return TableRow(
      children: [
        // Cột tiêu đề Ca học
        Container(
          height: 150, // Fixed minimum height for rows
          color: const Color(0xFFFDFDFD),
          alignment: Alignment.center,
          child: Text(
            shiftName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        // 7 ngày trong tuần
        ...List.generate(7, (dayIndex) {
          String dateKey = dateFormat.format(_weekDates[dayIndex]);
          List<dynamic> classes = weekData[dateKey]?[shiftIndex] ?? [];

          return Container(
            height: 150,
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(4),
            child: classes.isEmpty
                ? const SizedBox.shrink()
                : SingleChildScrollView(
                    child: Column(
                      children: classes.map((c) => _buildClassCard(c)).toList(),
                    ),
                  ),
          );
        }),
      ],
    );
  }

  Widget _buildClassCard(dynamic data) {
    String timeRange = "";
    if (data['gioBatDau'] != null && data['gioKetThuc'] != null) {
      // Format time from 15:00:00 to 15:00
      timeRange =
          "${data['gioBatDau'].substring(0, 5)} - ${data['gioKetThuc'].substring(0, 5)}";
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data['tenKhoaHoc'] ?? 'Khoa học',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF1565C0),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "Lớp: ${data['tenLop'] ?? ''}",
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          Text(
            "Giờ: $timeRange",
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          Text(
            "Phòng: ${data['diaDiem'] ?? 'Đang cập nhật'}",
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          if (data['hoTenGv'] != null)
            Text(
              "GV: ${data['hoTenGv']}",
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
