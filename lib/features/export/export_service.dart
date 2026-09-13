import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/work_entry.dart';

class ExportService {
  static Future<void> shareTxt(List<WorkEntry> entries) async {
    final dir = await getTemporaryDirectory(); final file = File('${dir.path}/workday-${DateTime.now().toIso8601String().substring(0,10)}.txt');
    final sorted=[...entries]..sort((a,b)=>a.date.compareTo(b.date)); final worked=sorted.where((e)=>e.status==WorkStatus.worked).length;
    await file.writeAsString('${sorted.map((e)=>'${e.date.split('-').reversed.join('/')} ${e.status==WorkStatus.worked?'✓':'×'}${e.note?.isNotEmpty==true?'  ${e.note}':''}').join('\n')}\n\nTotal $worked days\n');
    await SharePlus.instance.share(ShareParams(files:[XFile(file.path)], text:'Workday Noir export'));
  }
  static String csv(List<WorkEntry> entries){final sorted=[...entries]..sort((a,b)=>a.date.compareTo(b.date));String q(String s)=>'"${s.replaceAll('"','""')}"';return ['Date,Status,Note',...sorted.map((e)=>'${e.date},${e.status==WorkStatus.worked?'Worked':'Did not work'},${e.note==null?'':q(e.note!)}')].join('\n');}
}
