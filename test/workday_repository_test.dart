import 'package:flutter_test/flutter_test.dart';

enum TestWorkStatus { worked, didNotWork }

void main() {
  test('work status names are stable', () {
    expect(TestWorkStatus.worked.name, 'worked');
    expect(TestWorkStatus.didNotWork.name, 'didNotWork');
  });
}
