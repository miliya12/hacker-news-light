import 'package:flutter/material.dart';

void main() => runApp(HackerNewsLight());

class HackerNewsLight extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News Light',
      theme: ThemeData(primaryColor: Colors.amber),
      home: NewsEntriesPage(),
    );
  }
}

class NewsEntriesPage extends StatefulWidget {
  // StatefulなWidgetはcreateStateの関数内でbuildされる
  @override
  State createState() => NewsEntriesState();
}

class NewsEntriesState extends State<NewsEntriesPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News Light'),
      ),
      body: Center(
        child: Text('Hello, Flutter!'),
      ),
    );
  }
}
