import 'package:flutter_test/flutter_test.dart';
import 'package:virtuchat/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FirebaseAuthServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
