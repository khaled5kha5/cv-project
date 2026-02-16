import 'package:flutter/material.dart';

class PreviewCvScreen extends StatelessWidget {
  const PreviewCvScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview CV')),
      body: const Center(child: Text('CV preview will be rendered here')),
    );
  }
}
