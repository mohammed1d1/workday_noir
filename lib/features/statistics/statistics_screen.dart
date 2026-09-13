import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/date_utils.dart';
import '../../data/models/work_entry.dart';
import '../../data/repositories/workday_repository.dart';
import '../../shared/widgets/noir_card.dart';

class StatisticsScreen extends ConsumerWidget { const StatisticsScreen({super.key}); @override Widget build(BuildContext context,WidgetRef ref){final p=ref.watch(entriesProvider);return CupertinoPageScaffold(navigationBar:const CupertinoNavigationBar(largeTitle:Text('Statistics'),automaticallyImplyLeading:false),child:SafeArea(child:p.when(loading:()=>const Center(child:CupertinoActivityIndicator()),error:(_,__)=>const Center(child:Text('Something went wrong.')),data:(entries){final now=todayLocal();final month=entries.where((e)=>e.date.startsWith(monthKey(now))).toList();return ListView(padding:const EdgeInsets.all(20),children:[_Stats(title:'${DateFormat('MMMM yyyy').format(now)}',entries:month),const SizedBox(height:18),_Stats(title:'All time',entries:entries)];})));}
}
class _Stats extends StatelessWidget{final String title;final List<WorkEntry> entries;const _Stats({required this.title,required this.entries});@override Widget build(BuildContext context){final worked=entries.where((e)=>e.status==WorkStatus.worked).length;final rate=entries.isEmpty?0:(worked/entries.length*100).round();return NoirCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title.toUpperCase(),style:const TextStyle(fontSize:13,letterSpacing:1.2,color:CupertinoColors.systemGrey)),const SizedBox(height:18),Row(children:[Expanded(child:_Metric(label:'Worked',value:'$worked')),Expanded(child:_Metric(label:"Didn't work",value:'${entries.length-worked}')),Expanded(child:_Metric(label:'Rate',value:'$rate%'))]),const SizedBox(height:12),Text('Total recorded  ${entries.length}',style:const TextStyle(color:CupertinoColors.systemGrey))]));}}
class _Metric extends StatelessWidget{final String label,value;const _Metric({required this.label,required this.value});@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w700)),const SizedBox(height:4),Text(label,style:const TextStyle(color:CupertinoColors.systemGrey,fontSize:12))]);}
