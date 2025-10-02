import 'package:flutter/material.dart';

class CustomTask extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback onPressed;
  final bool showFlashIcon;
  final bool showVerifiedIcon;
  
  const CustomTask({
    Key? key,
    required this.title,
    required this.subtitle,
    this.isChecked = false,
    this.onChanged,
    required this.onPressed,
    this.showFlashIcon = false,
    this.showVerifiedIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 290,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        
        decoration: BoxDecoration(
          color: isChecked ? Colors.indigo.shade100 : Colors.blue[700],
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Transform.scale(
              scale: 1.4,
              child: Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: Colors.white,
                checkColor: Colors.black,
                fillColor: WidgetStateProperty.all(Colors.white),
                visualDensity: const VisualDensity(
                  horizontal: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide.none,
              ),
            ),
            
            const SizedBox(width: 11),
            
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isChecked ? Colors.white70 : Colors.white,
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isChecked ? Colors.white : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            
            const Spacer(),
            
            if (showFlashIcon)
              Padding(
                padding: const EdgeInsets.only(right: 7, top: 3),
                child: Icon(
                  IconData(0xf080, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                ),
              ),
                          
            if (showVerifiedIcon)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
              ),
            ),
            
            Container(
              width: 22,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}














































