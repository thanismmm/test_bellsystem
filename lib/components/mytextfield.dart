
import 'package:flutter/material.dart';

class Mytextfield extends StatelessWidget {

  final controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;


  const Mytextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.suffixIcon,
    this.keyboardType, required String? Function(dynamic value) validator,

    });

  @override
  Widget build(BuildContext context) {
    return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  
                  decoration: InputDecoration(enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)
                ),
                
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400)
                ),
            
                fillColor: Colors.grey.shade100,
                filled: true,
                hintText: hintText,
                
                suffixIcon: suffixIcon
                ),),
              );
  }
}