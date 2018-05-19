import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hacker_news_light/model/hacker_news_service_mock.dart';
import 'package:hacker_news_light/model/news_entry.dart';

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
  // _newsEntries stores newsEntries data.
  final List<NewsEntry> _newsEntries = [];

  // hackerNewsService is a instance of mock service for fetching data of news entries.
  final HackerNewsServiceMock hackerNewsService = HackerNewsServiceMock();

  // _biggerFontStyle set a font size.
  final TextStyle _biggerFontStyle = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News Light'),
      ),
      body: _buildBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    // get data of news entries.
    _getNewsEntries();
  }

  Widget _buildBody() {
    if (_newsEntries.isEmpty) {
      // display ProgressBar.
      return Center(
        child: Container(
          margin: EdgeInsets.only(top: 8.0),
          width: 32.0,
          height: 32.0,
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // display news entries as ListView.
      return _buildNewsEntriesListView();
    }
  }

  Widget _buildNewsEntriesListView() {
    /**
     * Create ListView with divider.
     * If the index is odd, return divider. If not, return column of a news entry.
     */
    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      if (index.isOdd) return Divider();

      final i = index ~/ 2;
      if (i < _newsEntries.length) {
        // return row widget.
        return _buildNewsEntryRow(_newsEntries[i]);
      } else {
        // end of list.
        return null;
      }
    });
  }

  Widget _buildNewsEntryRow(NewsEntry newsEntry) {
    // ListTile is a single fixed-height row that typically contains some text as well as a leading or trailing icon.
    // See: https://docs.flutter.io/flutter/material/ListTile-class.html
    return ListTile(
      title: Text(
        newsEntry.title,
        style: _biggerFontStyle,
      ),
    );
  }

  Future<Null> _getNewsEntries() async {
    final newsEntries = await hackerNewsService.getNewsEntries(1);
    // notice the change of the state and redraw the widget.
    setState(() {
      _newsEntries.addAll(newsEntries);
    });
  }
}
