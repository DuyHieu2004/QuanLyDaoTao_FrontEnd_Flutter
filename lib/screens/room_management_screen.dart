// file: lib/screens/room_management_screen.dart

import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final RoomService _roomService = RoomService();
  late Future<List<PhongThi>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    setState(() {
      _roomsFuture = _roomService.getAllRooms();
    });
  }

  // Dialog for both CREATING and EDITING a room
  void _showRoomDialog({PhongThi? room}) {
    final bool isEditing = room != null;
    final TextEditingController nameController = TextEditingController(
      text: isEditing ? room.tenPhong : '',
    );
    final TextEditingController capacityController = TextEditingController(
      text: isEditing ? room.soLuong.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Chỉnh sửa phòng' : 'Thêm phòng mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên phòng (ví dụ: A101)',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sức chứa',
                  prefixIcon: Icon(Icons.people),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final int? capacity = int.tryParse(
                  capacityController.text.trim(),
                );

                if (name.isEmpty || capacity == null || capacity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tên và sức chứa hợp lệ.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context); // Close dialog

                bool success;
                if (isEditing) {
                  success = await _roomService.updateRoom(
                    room.idPhong,
                    name,
                    capacity,
                  );
                } else {
                  success = await _roomService.createRoom(name, capacity);
                }

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing ? 'Đã cập nhật phòng!' : 'Đã tạo phòng!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadRooms(); // Refresh the list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thao tác không thành công.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Delete Confirmation Dialog
  void _confirmDelete(int idPhong) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa phòng học'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa phòng học này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await _roomService.deleteRoom(idPhong);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phòng học đã được xóa!'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadRooms();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Xóa phòng học thất bại. Có thể phòng đang được sử dụng.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Quản lý phòng",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        
        
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadRooms(),
        child: FutureBuilder<List<PhongThi>>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Hiện không có phòng. Nhấn + để thêm phòng mới."),
              );
            }

            final rooms = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.meeting_room,
                        color: Color(0xFF1E3C72),
                      ),
                    ),
                    title: Text(
                      room.tenPhong,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("Capacity: ${room.soLuong} seats"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRoomDialog(room: room),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(room.idPhong),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        
        onPressed: () =>
            _showRoomDialog(), // Passing null means we are creating a new room
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
