import 'package:flutter_test/flutter_test.dart';
import 'package:workday_noir/data/models/work_entry.dart';

void main() {
  test('WorkStatus enum exposes expected values', () {
    expect(WorkStatus.worked.name, 'worked');
    expect(WorkStatus.didNotWork.name, 'didNotWork');
  });
}
