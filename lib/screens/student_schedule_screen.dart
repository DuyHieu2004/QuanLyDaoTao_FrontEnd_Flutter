import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/schedule_service.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  DateTime _currentDate = DateTime.now();
  late Future<Map<String, dynamic>> _scheduleFuture;
  List<DateTime> _weekDates = [];
  String _filterType = 'all'; // 'all', 'class', 'exam'

  @override
  void initState() {
    super.initState();
    _calculateWeekDates();
    _loadSchedule();
  }

  void _calculateWeekDates() {
    int currentWeekday = _currentDate.weekday; // 1 = Monday, 7 = Sunday
    DateTime startOfWeek = _currentDate.subtract(Duration(days: currentWeekday - 1));
    _weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _loadSchedule() {
    _scheduleFuture = _scheduleService.getMyWeekSchedule(_currentDate);
  }

  void _changeWeek(int offsetDays) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: offsetDays));
      _calculateWeekDates();
      _loadSchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Thời khóa biểu", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  color: const Color(0xFF1E3C72),
                  tooltip: 'Tuần trước',
                ),
                Text(
                  "Tuần ${dateFormat.format(_weekDates.first)} - ${dateFormat.format(_weekDates.last)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3C72)),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: () => _changeWeek(7),
                  color: const Color(0xFF1E3C72),
                  tooltip: 'Tuần sau',
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Bộ lọc
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'all',
                  groupValue: _filterType,
                  onChanged: (val) => setState(() => _filterType = val!),
                  activeColor: const Color(0xFF1E3C72),
                ),
                const Text("Tất cả", style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Radio<String>(
                  value: 'class',
                  groupValue: _filterType,
                  onChanged: (val) => setState(() => _filterType = val!),
                  activeColor: const Color(0xFF1E3C72),
                ),
                const Text("Lịch học", style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Radio<String>(
                  value: 'exam',
                  groupValue: _filterType,
                  onChanged: (val) => setState(() => _filterType = val!),
                  activeColor: const Color(0xFF1E3C72),
                ),
                const Text("Lịch thi", style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Lỗi tải lịch: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }
                final data = snapshot.data;
                if (data == null) {
                  return const Center(child: Text("Không có dữ liệu"));
                }

                final items = data['items'] as List<dynamic>;
                
                // Chuẩn bị dữ liệu cho grid
                Map<String, Map<String, List<dynamic>>> weekData = {};
                for (var date in _weekDates) {
                  weekData[dateFormat.format(date)] = {'Morning': [], 'Afternoon': [], 'Evening': []};
                }

                for (var item in items) {
                  if (_filterType == 'class' && item['kind'] == 'Exam') continue;
                  if (_filterType == 'exam' && item['kind'] != 'Exam') continue;
                  
                  if (item['start'] != null) {
                    try {
                      DateTime itemDate = DateTime.parse(item['start']);
                      String dateKey = dateFormat.format(itemDate);
                      if (weekData.containsKey(dateKey)) {
                        String slot = item['slot'] ?? 'Morning'; // Morning, Afternoon, Evening
                        if (weekData[dateKey]!.containsKey(slot)) {
                          weekData[dateKey]![slot]!.add(item);
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
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                          ]
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
                              decoration: const BoxDecoration(color: Color(0xFFF0F4F8)),
                              children: [
                                _buildHeaderCell("Ca học"),
                                _buildHeaderCell("Thứ 2\n${dateFormat.format(_weekDates[0])}"),
                                _buildHeaderCell("Thứ 3\n${dateFormat.format(_weekDates[1])}"),
                                _buildHeaderCell("Thứ 4\n${dateFormat.format(_weekDates[2])}"),
                                _buildHeaderCell("Thứ 5\n${dateFormat.format(_weekDates[3])}"),
                                _buildHeaderCell("Thứ 6\n${dateFormat.format(_weekDates[4])}"),
                                _buildHeaderCell("Thứ 7\n${dateFormat.format(_weekDates[5])}"),
                                _buildHeaderCell("Chủ nhật\n${dateFormat.format(_weekDates[6])}"),
                              ],
                            ),
                            // Sáng Row
                            _buildShiftRow("Sáng\n(Ca 1)", 'Morning', weekData, dateFormat),
                            // Chiều Row
                            _buildShiftRow("Chiều\n(Ca 2)", 'Afternoon', weekData, dateFormat),
                            // Tối Row
                            _buildShiftRow("Tối\n(Ca 3)", 'Evening', weekData, dateFormat),
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
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3C72), fontSize: 13),
      ),
    );
  }

  TableRow _buildShiftRow(String shiftName, String slotKey, Map<String, Map<String, List<dynamic>>> weekData, DateFormat dateFormat) {
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
        ),
        // 7 ngày trong tuần
        ...List.generate(7, (dayIndex) {
          String dateKey = dateFormat.format(_weekDates[dayIndex]);
          List<dynamic> classes = weekData[dateKey]?[slotKey] ?? [];
          
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
        })
      ],
    );
  }

  Widget _buildClassCard(dynamic data) {
    final isExam = data['kind'] == 'Exam';
    final title = data['title'] ?? data['tenLop'] ?? 'Không rõ';
    final location = data['location'] ?? 'Không rõ';
    
    String timeRange = "";
    if (data['start'] != null) {
      timeRange = DateFormat('HH:mm').format(DateTime.parse(data['start']));
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isExam ? Colors.red.shade50 : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isExam ? Colors.red.shade200 : Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isExam) ...[
                const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isExam ? Colors.red.shade700 : const Color(0xFF1565C0)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("Giờ: $timeRange", style: const TextStyle(fontSize: 10, color: Colors.black87)),
          Text("Phòng: $location", style: const TextStyle(fontSize: 10, color: Colors.black87)),
        ],
      ),
    );
  }
}
