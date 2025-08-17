import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Bottom sheet for selecting and managing task labels
class LabelsBottomSheet extends StatefulWidget {
  final List<String> selectedLabels;
  final List<String> allLabels;
  final Function(List<String>) onLabelsChanged;

  const LabelsBottomSheet({
    super.key,
    required this.selectedLabels,
    required this.allLabels,
    required this.onLabelsChanged,
  });

  @override
  State<LabelsBottomSheet> createState() => _LabelsBottomSheetState();
}

class _LabelsBottomSheetState extends State<LabelsBottomSheet> {
  late List<String> _selectedLabels;
  late List<String> _allLabels;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newLabelController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedLabels = List.from(widget.selectedLabels);
    _allLabels = List.from(widget.allLabels);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newLabelController.dispose();
    super.dispose();
  }

  List<String> get _filteredLabels {
    if (_searchQuery.isEmpty) return _allLabels;
    return _allLabels
        .where(
          (label) => label.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _toggleLabel(String label) {
    setState(() {
      if (_selectedLabels.contains(label)) {
        _selectedLabels.remove(label);
      } else {
        _selectedLabels.add(label);
      }
    });
    widget.onLabelsChanged(_selectedLabels);
  }

  void _addNewLabel() {
    final newLabel = _newLabelController.text.trim();
    if (newLabel.isNotEmpty && !_allLabels.contains(newLabel)) {
      setState(() {
        _allLabels.add(newLabel);
        _selectedLabels.add(newLabel);
      });
      _newLabelController.clear();
      widget.onLabelsChanged(_selectedLabels);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildNewLabelSection(),
          _buildLabelsList(),
          _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.label, color: Colors.blue),
          SizedBox(width: AppConstants.smallPadding),
          const Text(
            'Your Labels',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.mediumPadding),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search labels...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.mediumPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildNewLabelSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.mediumPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newLabelController,
              decoration: InputDecoration(
                hintText: 'Add new label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppConstants.mediumPadding,
                  vertical: AppConstants.smallPadding,
                ),
              ),
              onSubmitted: (_) => _addNewLabel(),
            ),
          ),
          SizedBox(width: AppConstants.smallPadding),
          ElevatedButton(
            onPressed: _addNewLabel,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.mediumPadding,
                vertical: AppConstants.smallPadding,
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelsList() {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(AppConstants.mediumPadding),
        itemCount: _filteredLabels.length,
        itemBuilder: (context, index) {
          final label = _filteredLabels[index];
          final isSelected = _selectedLabels.contains(label);

          return Card(
            margin: EdgeInsets.only(bottom: AppConstants.smallPadding),
            child: ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              title: Text(label),
              onTap: () => _toggleLabel(label),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.mediumPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppConstants.mediumPadding),
          ),
          child: const Text('Done'),
        ),
      ),
    );
  }
}
