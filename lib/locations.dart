import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_riverpod/constants.dart';
import 'package:bottom_navigation_riverpod/screens.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class BooksLocation extends BeamLocation<BeamState> {
  BooksLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => [
        '/home/books/:bookId',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    debugLog("BooksLocation | buildPages() | invoked");
    final pages = [
      BeamPage(
        key: ValueKey('books'),
        title: 'Books',
        type: BeamPageType.noTransition,
        child: BooksScreen(),
      ),
      if (state.pathParameters.containsKey('bookId'))
        BeamPage(
          key: ValueKey('book-${state.pathParameters['bookId']}'),
          title: books.firstWhere(
              (book) => book['id'] == state.pathParameters['bookId'])['title'],
          child: BookDetailsScreen(
            book: books.firstWhere(
                (book) => book['id'] == state.pathParameters['bookId']),
          ),
        ),
    ];

    debugLog("BooksLocation | buildPages() | "
        "pages to be returned: ${pages.map((page) => page.key)}");
    return pages;
  }
}

class BluetoothLocation extends BeamLocation<BeamState> {
  BluetoothLocation(RouteInformation routeInformation)
      : super(routeInformation);
  @override
  List<String> get pathPatterns => [
        '/home/bluetooth',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      BeamPage(
        key: ValueKey('bluetooth'),
        title: 'Bluetooth',
        child: BluetoothScreen(),
      ),
    ];
    return pages;
  }
}

class ArticlesLocation extends BeamLocation<BeamState> {
  ArticlesLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/home/articles/:articleId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    debugLog("ArticlesLocation | buildPages() | invoked");
    final pages = [
      BeamPage(
        key: ValueKey('articles'),
        title: 'Articles',
        type: BeamPageType.noTransition,
        child: ArticlesScreen(),
      ),
      if (state.pathParameters.containsKey('articleId'))
        BeamPage(
          key: ValueKey('articles-${state.pathParameters['articleId']}'),
          title: articles.firstWhere((article) =>
              article['id'] == state.pathParameters['articleId'])['title'],
          child: ArticleDetailsScreen(
            article: articles.firstWhere((article) =>
                article['id'] == state.pathParameters['articleId']),
          ),
        ),
    ];

    debugLog("ArticlesLocation | buildPages() | "
        "pages to be returned: ${pages.map((page) => page.key)}");
    return pages;
  }
}
