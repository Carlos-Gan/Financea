
import 'package:financea/data/utility.dart';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Income extends StatelessWidget {
  const Income({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: AppColors.grayIcons,
                  ),
                  child: Icon(
                    FontAwesomeIcons.arrowUp,
                    size: 20,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  AppStr.get('income'),
                  style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              '\$ ${calculateTotalIncome()}',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}