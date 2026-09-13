import 'package:flutter_test/flutter_test.dart';
import 'package:workday_noir/data/models/work_entry.dart';

test('WorkStatus serializes by enum name', () { expect(WorkStatus.worked.name, 'worked'); expect(WorkStatus.didNotWork.name, 'didNotWork'); });
