

import 'package:connect/models/home_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main () {
  group('findHomeLevel Check', () {
    test("star 5", () {
      expect(findHomeLevel(5), HomeLevel.rookie_warrior);
    });
    test("star 10", () {
      expect(findHomeLevel(10), HomeLevel.go_getter);
    });
    test('star 5000', () {
      expect(findHomeLevel(5000), HomeLevel.legend);
    });
    test("star 4999", () {
      expect(findHomeLevel(4999), HomeLevel.hall_of_fame);
    });
    test("star 0", () {
      expect(findHomeLevel(0), HomeLevel.rookie_warrior);
    });
    test("star -1", () {
      expect(findHomeLevel(-1), HomeLevel.rookie_warrior);
    });
  });

}