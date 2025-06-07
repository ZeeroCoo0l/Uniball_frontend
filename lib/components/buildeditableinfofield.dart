import 'package:flutter/material.dart';


class EditableInfoField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final bool readOnly;

  const EditableInfoField({
    Key? key,
    required this.title,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 8),
              if (!readOnly)
                Text(
                  'Redigera $title',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6CBC8C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Card(
            elevation: 4, // Skuggans styrka
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Color(0xFFBCD0B9),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                readOnly: readOnly,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}