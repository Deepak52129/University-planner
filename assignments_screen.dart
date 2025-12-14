// lib/screens/assignments_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Assignment {
  String title;
  String assignee;
  DateTime due;
  String priority; // "High", "Medium", "Low"

  Assignment({
    required this.title,
    required this.assignee,
    required this.due,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'assignee': assignee,
        'due': due.toIso8601String(),
        'priority': priority,
      };

  static Assignment fromJson(Map<String, dynamic> j) => Assignment(
        title: j['title'] ?? '',
        assignee: j['assignee'] ?? '',
        due: DateTime.parse(j['due'] as String),
        priority: j['priority'] ?? 'Medium',
      );
}

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final String _prefsKey = 'assignments_list_v1';
  List<Assignment> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? <String>[];
    setState(() {
      _items = raw
          .map((s) => Assignment.fromJson(json.decode(s) as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _items.map((a) => json.encode(a.toJson())).toList();
    await prefs.setStringList(_prefsKey, raw);
  }

  Future<void> _showAddEditDialog({Assignment? edit, int? editIndex}) async {
    String title = edit?.title ?? '';
    String assignee = edit?.assignee ?? '';
    DateTime due = edit?.due ?? DateTime.now().add(const Duration(days: 3));
    String priority = edit?.priority ?? 'Medium';

    final formKey = GlobalKey<FormState>();

    Future<void> pickDate() async {
      final d = await showDatePicker(
        context: context,
        initialDate: due,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (d != null) {
        final t = TimeOfDay.fromDateTime(due);
        due = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      }
    }

    Future<void> pickTime() async {
      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(due));
      if (t != null) {
        due = DateTime(due.year, due.month, due.day, t.hour, t.minute);
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(edit == null ? 'Add Assignment' : 'Edit Assignment'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: title,
                  decoration: const InputDecoration(labelText: 'Task name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  onSaved: (v) => title = v!.trim(),
                ),
                TextFormField(
                  initialValue: assignee,
                  decoration: const InputDecoration(labelText: 'Assignee (name)'),
                  onSaved: (v) => assignee = v?.trim() ?? '',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await pickDate();
                          setState(() {}); // little trick to reflect picked value in dialog
                        },
                        child: Text('Date: ${_formatDate(due)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await pickTime();
                          setState(() {});
                        },
                        child: Text('Time: ${_formatTime(due)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  items: const [
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                  ],
                  onChanged: (v) => priority = v ?? 'Medium',
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState != null && formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newAssignment = Assignment(title: title, assignee: assignee, due: due, priority: priority);
      setState(() {
        if (editIndex != null) {
          _items[editIndex] = newAssignment;
        } else {
          _items.insert(0, newAssignment);
        }
      });
      await _save();
    }
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$mm $ampm';
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'High':
        return Colors.green;
      case 'Low':
        return Colors.cyan;
      default:
        return Colors.orange;
    }
  }

  void _removeAt(int index) async {
    setState(() => _items.removeAt(index));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _items.isEmpty
          ? const Center(child: Text('No assignments. Tap + to add one.'))
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final a = _items[i];
                return Dismissible(
                  key: Key(a.title + a.due.toIso8601String() + i.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeAt(i),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text(
                        (a.assignee.isEmpty ? a.title.characters.first : a.assignee.characters.first).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${a.assignee.isEmpty ? 'Unassigned' : a.assignee} • ${_formatDate(a.due)} • ${_formatTime(a.due)}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _priorityColor(a.priority),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(a.priority, style: const TextStyle(color: Colors.white)),
                    ),
                    onTap: () => _showAddEditDialog(edit: a, editIndex: i),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
