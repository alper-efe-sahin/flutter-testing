import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(
    () {
      mockNewsService = MockNewsService();
    },
  );

  final articlesFromService = [
    Article(title: "Test1", content: "Test 1 content"),
    Article(title: "Test2", content: "Test 2 content"),
    Article(title: "Test3", content: "Test 3 content"),
  ];

  void arrangeNewsServiceReturns3Articles() { // normal list
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async => articlesFromService,
    );
  }

  void arrangeNewsServiceReturns3ArticlesAfter2SecondWait() { // future list 
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async {
        await Future.delayed(const Duration(seconds: 2));
        return articlesFromService;
      },
    );
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets(
    "title is displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text("News"), findsOneWidget);
    },
  );

  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2SecondWait();
      await tester.pumpWidget(createWidgetUnderTest()); //widgeti oluşturmaya sağlıyor, yani widgeti sağlıyor aslında
      await tester.pump(); // build methodu gibi widgeti build ediyor
      expect(find.byKey(const Key("progress-indicator")), findsOneWidget);

      await tester.pumpAndSettle(); // This essentially waits for all animations to have completed. wait until them
    },
  );

  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump();

      for (var article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
