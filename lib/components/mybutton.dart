import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget {

  final Function()? onTap;
  final String text;

  const Mybutton({super.key, 
  required this.onTap,
  required this.text,
  
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: onTap ,
      child: Container(
        
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 25.0),
        
        
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
        
          child:
          Center(child: Text("Login", 
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold
            
            ),)),
          
        
      ),
    );
  }
}