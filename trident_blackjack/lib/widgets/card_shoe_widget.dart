import 'package:flutter/material.dart';

class CardShoeWidget extends StatefulWidget {
  final int totalCards;
  final int cardsRemaining;

  CardShoeWidget({required this.totalCards, required this.cardsRemaining});

  @override
  // ignore: library_private_types_in_public_api
  _CardShoeWidgetState createState() => _CardShoeWidgetState();
}

class _CardShoeWidgetState extends State<CardShoeWidget> {
  @override
  Widget build(BuildContext context) {
    int decksRemaining = (widget.cardsRemaining / 52).ceil();

    return Column(
      children: [
        Row(
          children: List.generate(decksRemaining, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                'assets/card_back.png', 
                width: 30, 
                height: 50,
              ),
            );
          }),
        ),
        SizedBox(height: 10),
        Text("Cards remaining: ${widget.cardsRemaining}"),
      ],
    );
  }
}
