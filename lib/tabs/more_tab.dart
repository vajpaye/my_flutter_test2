import 'package:flutter/material.dart';

class MoreTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('More Item 1'),
        ),
        ListTile(
          title: Text('More Item 2'),
        ),
        ListTile(
          title: Text('More Item 3'),
        ),
      ],
    );
  }
}
