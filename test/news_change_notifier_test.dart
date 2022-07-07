import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

/* Do not use, use mocks...  >  class BadMockNewService implements NewsService {
  bool getArticlesCalled = false;

  @override
  Future<List<Article>> getArticles() async {
    getArticlesCalled = true;

    return [
      Article(title: "Test1", content: "Test 1 content"),
      Article(title: "Test2", content: "Test 2 content"),
      Article(title: "Test3", content: "Test 3 content"),
    ];
  }
} */

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut; //system under test
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test(
    "initial values are correct",
    () {
      expect(sut.articles, []);
      expect(sut.isLoading, false);
    },
  );

  group(
    "getArticles",
    () {
      final articlesFromService = [
        Article(title: "Test1", content: "Test 1 content"),
        Article(title: "Test2", content: "Test 2 content"),
        Article(title: "Test3", content: "Test 3 content"),
      ];

      void arrangeNewsServiceReturns3Articles() {
        when(() => mockNewsService.getArticles()).thenAnswer(
          (_) async => articlesFromService,
        );
      }

      test(
        "gets articles using the NewsService",
        () async {
          /*   when(() => mockNewsService.getArticles()).thenAnswer((_) async => []); */
          // we call arrangenews... to avoid code duplications.
          // It does not matter is it empty or not

          arrangeNewsServiceReturns3Articles();
          await sut.getArticles();
          verify(() => mockNewsService.getArticles()).called(1);
        },
      );

      test(
        """indicates loading of data,
        sets articles to the ones from the setvice,
        indicates that data is not being loaded anymore""",
        () async {
          arrangeNewsServiceReturns3Articles();
          final future = sut.getArticles();

          expect(sut.isLoading, true);
          await future;

          expect(
            sut.articles,
            articlesFromService,
          );

          expect(sut.isLoading, false);
        },
      );
    },
  );
}
