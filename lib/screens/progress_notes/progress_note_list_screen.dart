import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/progress_note.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class ProgressNoteListScreen extends ConsumerStatefulWidget {
  final int admissionId;

  const ProgressNoteListScreen({
    super.key,
    required this.admissionId,
  });

  @override
  ConsumerState<ProgressNoteListScreen> createState() => _ProgressNoteListScreenState();
}

class _ProgressNoteListScreenState extends ConsumerState<ProgressNoteListScreen> {
  List<ProgressNote> _progressNotes = [];
  List<String> _problems = [];
  bool _isLoading = true;
  String? _selectedProblem;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProgressNotes();
    _loadProblems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(progressNoteRepositoryProvider);
      
      List<ProgressNote> notes;
      if (_selectedProblem != null) {
        notes = await repository.getProgressNotesByProblem(widget.admissionId, _selectedProblem!);
      } else if (_searchController.text.isNotEmpty) {
        notes = await repository.searchProgressNotes(widget.admissionId, _searchController.text);
      } else {
        notes = await repository.getProgressNotesByAdmissionId(widget.admissionId);
      }

      setState(() {
        _progressNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _loadProblems() async {
    try {
      final repository = ref.read(progressNoteRepositoryProvider);
      final problems = await repository.getUniqueProblems(widget.admissionId);
      
      setState(() {
        _problems = problems;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNotesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหา Progress Notes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadProgressNotes();
                  },
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _loadProgressNotes(),
      ),
    );
  }

  Widget _buildFilterChips() {
    if (_problems.isEmpty && _selectedProblem == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedProblem != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_selectedProblem!),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    _selectedProblem = null;
                  });
                  _loadProgressNotes();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (_progressNotes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('ไม่มี Progress Notes'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProgressNotes,
      child: ListView.builder(
        itemCount: _progressNotes.length,
        itemBuilder: (context, index) {
          final note = _progressNotes[index];
          return _buildNoteCard(note);
        },
      ),
    );
  }

  Widget _buildNoteCard(ProgressNote note) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _navigateToDetail(note.noteId!),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (note.problem != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note.problem!,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(note.noteDateTime),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // S.O.A.P. sections
              if (note.subjective != null) ...[
                _buildSOAPSection('S', note.subjective!),
                const SizedBox(height: 4),
              ],
              if (note.objective != null) ...[
                _buildSOAPSection('O', note.objective!),
                const SizedBox(height: 4),
              ],
              if (note.assessment != null) ...[
                _buildSOAPSection('A', note.assessment!),
                const SizedBox(height: 4),
              ],
              if (note.plan != null) ...[
                _buildSOAPSection('P', note.plan!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOAPSection(String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getSOAPColor(title),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getSOAPColor(String section) {
    switch (section) {
      case 'S':
        return Colors.green;
      case 'O':
        return Colors.blue;
      case 'A':
        return Colors.orange;
      case 'P':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('กรองตาม Problem'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              ListTile(
                title: const Text('ทั้งหมด'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: _selectedProblem,
                  onChanged: (value) {
                    setState(() {
                      _selectedProblem = value;
                    });
                    Navigator.pop(context);
                    _loadProgressNotes();
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _problems.length,
                  itemBuilder: (context, index) {
                    final problem = _problems[index];
                    return ListTile(
                      title: Text(problem),
                      leading: Radio<String>(
                        value: problem,
                        groupValue: _selectedProblem,
                        onChanged: (value) {
                          setState(() {
                            _selectedProblem = value;
                          });
                          Navigator.pop(context);
                          _loadProgressNotes();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToForm({int? noteId}) {
    Navigator.pushNamed(
      context,
      '/progress-notes/form',
      arguments: {
        'admissionId': widget.admissionId,
        'noteId': noteId,
      },
    ).then((result) {
      if (result == true) {
        _loadProgressNotes();
        _loadProblems();
      }
    });
  }

  void _navigateToDetail(int noteId) {
    Navigator.pushNamed(
      context,
      '/progress-notes/detail',
      arguments: {
        'noteId': noteId,
      },
    ).then((result) {
      if (result == true) {
        _loadProgressNotes();
        _loadProblems();
      }
    });
  }
}
