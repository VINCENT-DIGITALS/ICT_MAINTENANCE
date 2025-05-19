import 'package:flutter/material.dart';

Widget buildDropdownField(
  BuildContext context,
  String label,
  String? value,
  List<String> options,
  Function(String) onSelect, {
  FormFieldValidator<String>? validator,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool readOnly = false,
  bool searchable = true, // New parameter to enable/disable search
}) {
  return FormField<String>(
    validator: validator,
    initialValue: value,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (FormFieldState<String> state) {
      final bool hasError = state.hasError;
      final bool hasValue = value != null && value.isNotEmpty;
      
      // SearchableDropdown is a StatefulWidget that handles the search functionality
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchable)
            _SearchableDropdown(
              label: label,
              value: value,
              options: options,
              onSelect: (newValue) {
                onSelect(newValue);
                state.didChange(newValue);
              },
              hasError: hasError,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              readOnly: readOnly,
            )
          else
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: readOnly ? Colors.grey[50] : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError
                      ? const Color(0xFFFF5963)
                      : Color(0xFFB0B0B0),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: value,
                          isExpanded: true,
                          icon: suffixIcon ?? Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                          hint: Text(
                            label,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: readOnly 
                            ? null 
                            : (String? newValue) {
                                if (newValue != null) {
                                  onSelect(newValue);
                                  state.didChange(newValue);
                                }
                              },
                          items: options.map<DropdownMenuItem<String>>((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 5),
              child: Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
        ],
      );
    },
  );
}

// Custom SearchableDropdown StatefulWidget
class _SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> options;
  final Function(String) onSelect;
  final bool hasError;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;

  const _SearchableDropdown({
    Key? key,
    required this.label,
    this.value,
    required this.options,
    required this.onSelect,
    required this.hasError,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<_SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  
  bool _isDropdownOpen = false;
  List<String> _filteredOptions = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.value ?? '';
    _filteredOptions = List.from(widget.options);
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !widget.readOnly) {
        _openDropdown();
      } else {
        _closeDropdown();
      }
    });
  }
  
  @override
  void didUpdateWidget(_SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _searchController.text = widget.value ?? '';
    }
    
    if (widget.options != oldWidget.options) {
      _filteredOptions = List.from(widget.options);
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterOptions(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredOptions = List.from(widget.options);
      });
    } else {
      setState(() {
        _filteredOptions = widget.options
            .where((option) => option.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
    
    // Rebuild the overlay with filtered options
    _updateOverlay();
  }

  void _openDropdown() {
    _closeDropdown();
    _isDropdownOpen = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _updateOverlay();
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;
    }
  }

  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _selectOption(String option) {
    widget.onSelect(option);
    _searchController.text = option;
    _closeDropdown();
    _focusNode.unfocus();
  }

  OverlayEntry _createOverlayEntry() {
    // Find the render box of the field
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    // Get the position of the field
    final offset = renderBox.localToGlobal(Offset.zero);
    
    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredOptions.length,
                itemBuilder: (context, index) {
                  final option = _filteredOptions[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      option,
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () => _selectOption(option),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = widget.value != null && widget.value!.isNotEmpty;
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: widget.readOnly ? Colors.grey[50] : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.hasError
                    ? const Color(0xFFFF5963)
                    : Color(0xFFB0B0B0),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                border: InputBorder.none,
                hintText: widget.label,
                hintStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon ?? Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ),
              onChanged: (value) {
                _filterOptions(value);
              },
              onTap: () {
                if (!widget.readOnly) {
                  _openDropdown();
                }
              },
            ),
          ),
          
          // Floating label on the border line when value exists
          if (hasValue)
            Positioned(
              left: 10,
              top: -8, // Position to overlap with border
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white, // Background to hide the border line
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
