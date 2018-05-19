import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hacker_news_light/model/hacker_news_service.dart';
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

// define the type of the callback function for FavoriteButton.
typedef void FavoritePressedCallback(
    NewsEntry newsEntry, bool isAlreadySaved, Set<NewsEntry> savedEntries);

/**
 * Favorite button
 */
// The state for FavoriteButton is managed by the parent Widget, NewsEntriesPage.
class FavoriteButton extends StatelessWidget {
  // NewsEntry is one user favorites.
  final NewsEntry newsEntry;

  // savedEntries is a unique list of NewsEntries.
  // Set is a collection of objects in which each object can occur only once.
  // See: https://api.dartlang.org/stable/1.24.3/dart-core/Set-class.html
  final Set<NewsEntry> savedEntries;

  // handleFavoritePressed is called when user presses a favorite button.
  final FavoritePressedCallback handleFavoritePressed;

  // isAlreadySaved is a flag whether the news entry has been favorited.
  final bool isAlreadySaved;

  // Constructor
  FavoriteButton(
      {@required this.newsEntry,
      @required this.savedEntries,
      @required this.handleFavoritePressed})
      : isAlreadySaved = savedEntries.contains(newsEntry);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: IconButton(
        icon: Icon(
          isAlreadySaved ? Icons.favorite : Icons.favorite_border,
          color: isAlreadySaved ? Colors.red : null,
        ),
        onPressed: () {
          handleFavoritePressed(newsEntry, isAlreadySaved, savedEntries);
        },
      ),
    );
  }
}

/**
 * Main layout of news entries list page
 */
class NewsEntriesPage extends StatefulWidget {
  // StatefulなWidgetはcreateStateの関数内でbuildされる
  @override
  State createState() => NewsEntriesState();
}

class NewsEntriesState extends State<NewsEntriesPage> {
  // _newsEntries stores newsEntries data.
  final List<NewsEntry> _newsEntries = [];

  // _savedEntries stores the news entries favorited.
  final Set<NewsEntry> _savedEntries = Set<NewsEntry>();

  // _refreshIndicatorKey is the identifier of the RefreshIndicatorState.
  // It's unique across the app.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // hackerNewsService is a instance of mock service for fetching data of news entries.
  final HackerNewsService hackerNewsService = HackerNewsService();

  // _biggerFontStyle set a font size.
  final TextStyle _biggerFontStyle = TextStyle(fontSize: 18.0);

  _handleFavoritePressed(
      NewsEntry newsEntry, bool isAlreadySaved, Set<NewsEntry> savedEntries) {
    // notice that the favorite button is pressed.
    setState(
      () {
        // If the news entry has been already favorited, unfavorite it.
        // Otherwise, favorite it.
        if (isAlreadySaved) {
          savedEntries.remove(newsEntry);
        } else {
          savedEntries.add(newsEntry);
        }
      },
    );
  }

  // variables for control scroll.
  int _nextPage = 1;
  bool _isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hacker News Light'),
        // display navigation item and set the eventHandler to it.
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _navigateToSavedPage,
          )
        ],
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
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _getInitialNewsEntries,
        // display news entries as ListView.
        child: _buildNewsEntriesListView(),
      );
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
          return Center(
              child: Container(
            margin: EdgeInsets.only(top: 8.0),
            width: 32.0,
            height: 32.0,
            child: CircularProgressIndicator(),
          ));
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
      // display badge.
      leading: _buildBadge(newsEntry.points),
      // display the information of the news entry as subtitle.
      subtitle:
          Text('${newsEntry.domain} | ${newsEntry.commentsCount}comments.'),
      // display a favorite button and register callback handler.
      trailing: FavoriteButton(
        newsEntry: newsEntry,
        savedEntries: _savedEntries,
        handleFavoritePressed: _handleFavoritePressed,
      ),
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

  // _navigateToSavedPage navigate from AppHome to the favorite news list page.
  void _navigateToSavedPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      // tiles is a row of list.
      final tiles = _savedEntries.map(
        (entry) {
          return ListTile(
            title: Text(
              entry.title,
              style: _biggerFontStyle,
            ),
          );
        },
      );
      // divided transforms tiles to dividedTiles
      final divided = ListTile
          .divideTiles(
            context: context,
            tiles: tiles,
          )
          .toList();

      // return the Widget of favorite news entries list view.
      return Scaffold(
        appBar: AppBar(
          title: Text('Saved Entries'),
        ),
        body: ListView(children: divided),
      );
    }));
  }
}
