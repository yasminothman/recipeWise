import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class InfoPage extends StatefulWidget {
  final VoidCallback onOkayPressed;
  const InfoPage({
    super.key,
    required this.onOkayPressed,
  });

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6F6CB),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/info.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Please ensure the image taken or uploaded is clear.',
              style: GoogleFonts.jost(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF245651)),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'When taking a picture, ensure space is well lit.',
              style: GoogleFonts.jost(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF245651)),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Put your ingredient on a flat surface.',
              style: GoogleFonts.jost(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF245651)),
            ),
            SizedBox(height: 40),
            SizedBox(
              height: 50,
              width: 150,
              child: ElevatedButton(
                onPressed: widget.onOkayPressed,
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF245651)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFFE6F6CB))),
                child: Text(
                  'Got it!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
