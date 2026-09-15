import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import 'add_on_chip.dart';

/// Text field + add button that builds a list of add-on tags (e.g. جبنة،
/// صوص), rendered as removable chips underneath.
class AddOnsInput extends StatefulWidget {
  const AddOnsInput({
    super.key,
    required this.initialTags,
    required this.onChanged,
  });

  final List<String> initialTags;
  final ValueChanged<List<String>> onChanged;

  @override
  State<AddOnsInput> createState() => _AddOnsInputState();
}

class _AddOnsInputState extends State<AddOnsInput> {
  late final List<String> _tags = List<String>.of(widget.initialTags);
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tags.add(text);
      _controller.clear();
    });
    widget.onChanged(_tags);
  }

  void _removeTag(int index) {
    setState(() => _tags.removeAt(index));
    widget.onChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.right,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addTag(),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.navy,
                ),
                decoration: InputDecoration(
                  hintText: 'أضف إضافة مثل جبنة، صوص',
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: BrandColors.hintGray,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: BrandColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: BrandColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: BrandColors.navy, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: BrandColors.orange,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _addTag,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: <Widget>[
              for (int i = 0; i < _tags.length; i++)
                AddOnChip(label: _tags[i], onRemove: () => _removeTag(i)),
            ],
          ),
        ],
      ],
    );
  }
}
