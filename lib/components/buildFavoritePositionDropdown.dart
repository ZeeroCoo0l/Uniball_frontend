import 'package:uniball_frontend_2/entities/userClient.dart';
import 'package:flutter/material.dart';

class FavoritePositionDropdown extends StatelessWidget {
  final Position selectedPosition;
  final Function(Position?) onChanged;
  final Map<Position, String> positionLabels;

  const FavoritePositionDropdown({
    Key? key,
    required this.selectedPosition,
    required this.onChanged,
    required this.positionLabels,
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
                'Favoritposition',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Välj favoritposition',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6CBC8C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Color(0xFFBCD0B9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<Position>(
              value: selectedPosition != Position.NOPOSITION ? selectedPosition : null,
              isExpanded: true,
              underline: SizedBox(),
              hint: Text('Välj favoritposition'),
              onChanged: onChanged,
              items: Position.values.map((position) {
                return DropdownMenuItem(
                  value: position,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/teamShirt.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Text(positionLabels[position]!),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
