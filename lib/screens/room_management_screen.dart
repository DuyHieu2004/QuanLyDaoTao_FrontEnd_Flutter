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
    final TextEditingController nameController = TextEditingController(text: isEditing ? room.tenPhong : '');
    final TextEditingController capacityController = TextEditingController(text: isEditing ? room.soLuong.toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Room Name (e.g., A101)', prefixIcon: Icon(Icons.meeting_room)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity', prefixIcon: Icon(Icons.people)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final int? capacity = int.tryParse(capacityController.text.trim());

                if (name.isEmpty || capacity == null || capacity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid name and capacity.')));
                  return;
                }

                Navigator.pop(context); // Close dialog

                bool success;
                if (isEditing) {
                  success = await _roomService.updateRoom(room.idPhong, name, capacity);
                } else {
                  success = await _roomService.createRoom(name, capacity);
                }

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Room updated!' : 'Room created!'), backgroundColor: Colors.green)
                  );
                  _loadRooms(); // Refresh the list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation failed.'), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3C72)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
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
        title: const Text('Delete Room'),
        content: const Text('Are you sure you want to delete this room? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await _roomService.deleteRoom(idPhong);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room deleted!'), backgroundColor: Colors.green));
                _loadRooms();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete room. It might be in use.'), backgroundColor: Colors.red));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Room Management", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadRooms(),
        child: FutureBuilder<List<PhongThi>>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No rooms available. Tap + to add one."));
            }

            final rooms = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.meeting_room, color: Color(0xFF1E3C72)),
                    ),
                    title: Text(room.tenPhong, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text("Capacity: ${room.soLuong} seats"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRoomDialog(room: room),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
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
        backgroundColor: const Color(0xFF1E3C72),
        onPressed: () => _showRoomDialog(), // Passing null means we are creating a new room
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}