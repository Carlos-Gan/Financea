import 'package:financea/data/utility.dart';
import 'package:financea/utils/app_str.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Balance extends StatelessWidget {
  const Balance({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStr.get('balance'),
                        style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                      ),
                      Text(
                        '\$ ${calculateTotal()}',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(width: 20),
          Icon(FontAwesomeIcons.ellipsis, size: 20, color: Colors.white),
        ],
      ),
    );
  }
}