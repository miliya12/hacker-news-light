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

  // variables for control scroll.
  int _nextPage = 1;
  bool _isLastPage = false;

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
    _getInitialNewsEntries();
  }

  Widget _buildBody() {
    if (_newsEntries.isEmpty) {
      // display ProgressBar.
      return Center(
        // Container is a  convenience widget that combines common painting, positioning, and sizing widgets.
        // See: https://docs.flutter.io/flutter/widgets/Container-class.html
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
      } else if (i == _newsEntries.length) {
        // if user reaches the end of data.

        // if the loaded page is the last one,
        if (_isLastPage) {
          // end of list.
          return null;
        } else {
          // get the next page's data of news entries.
          _getNewsEntries();
          // display ProgressBar.
          return Center (
            child: Container(
              margin: EdgeInsets.only(top: 8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            )
          );
        }
      } else if (i > _newsEntries.length) {
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
      // diplay badge.
      leading: _buildBadge(newsEntry.points),
    );
  }

  Widget _buildBadge(int points) {
    // badge
    return Container(
      margin: const EdgeInsets.only(bottom: 2.0),
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        // if points is not good(less than 100) or points is none(null), draw the icon with red. Otherwise, draw it with green.
        color: (points == null || points < 100) ? Colors.red : Colors.green,
        shape: BoxShape.circle,
      ),
      // the content of badge.
      child: Container(
        padding: EdgeInsets.all(1.0),
        child: Center(
          child: Text(
            // if point's value is null, display empty text. If not, display points.
            points == null ? '' : '$points',
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  Future<Null> _getInitialNewsEntries() async {
    _nextPage = 1;
    await _getNewsEntries();
  }

  Future<Null> _getNewsEntries() async {
    // get the data of news entries corresponding to _nextPage
    final newsEntries = await hackerNewsService.getNewsEntries(_nextPage);
    if (newsEntries.isEmpty) {
      // notice the reach of last page.
      setState(() {
        _isLastPage = true;
      });
    } else {
      // notice the change of the state and redraw the widget.
      setState(() {
        // append the new data to the list of news entries.
        _newsEntries.addAll(newsEntries);
        _nextPage++;
      });
    }
  }
}
