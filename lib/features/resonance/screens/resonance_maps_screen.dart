import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_map.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/resonance_map_experience.dart';
import '../providers/resonance_map_experience_provider.dart';
import '../providers/resonance_map_threads_provider.dart';
import '../providers/resonance_maps_provider.dart';
import 'resonance_thread_detail_screen.dart';

class ResonanceMapsScreen extends ConsumerWidget {
  const ResonanceMapsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maps = ref.watch(resonanceMapsProvider);
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final byId = {for (final vent in vents) vent.id: vent};
    return Scaffold(backgroundColor: VentvoColors.background, appBar: AppBar(title: const Text('Maps'), centerTitle: true), body: maps.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      error: (_, _) => const Center(child: Text('Maps could not be loaded yet.')),
      data: (items) => items.isEmpty ? const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 36), child: Text('No landscape has taken shape yet.\n\nAs experiences become meaningfully connected, Ventvo can reveal paths between them.', textAlign: TextAlign.center, style: TextStyle(color: VentvoColors.textMuted, fontSize: 13, height: 1.6)))) : ListView.separated(padding: const EdgeInsets.all(18), itemCount: items.length, separatorBuilder: (_, _) => const SizedBox(height: 16), itemBuilder: (context, i) => _MapPreview(map: items[i], onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResonanceMapDetailScreen(map: items[i], ventsById: byId))))),
    ));
  }
}

class _MapPreview extends StatelessWidget {
  final ResonanceMap map; final VoidCallback onTap;
  const _MapPreview({required this.map, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Container(height: 210, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: VentvoColors.border)), child: Stack(children: [Positioned.fill(child: _Art(map: map)), const Positioned(left: 16, top: 15, child: Text('A LANDSCAPE OF EXPERIENCES', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.3))), Positioned(left: 16, bottom: 15, child: Text('${map.experienceIds.length} connected experiences', style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 12))), const Positioned(right: 16, bottom: 13, child: Icon(Icons.arrow_forward_rounded, size: 17, color: VentvoColors.textMuted))])));
}

class ResonanceMapDetailScreen extends ConsumerStatefulWidget {
  final ResonanceMap map; final Map<String, Vent> ventsById;
  const ResonanceMapDetailScreen({super.key, required this.map, required this.ventsById});
  @override
  ConsumerState<ResonanceMapDetailScreen> createState() => _ResonanceMapDetailScreenState();
}
class _ResonanceMapDetailScreenState extends ConsumerState<ResonanceMapDetailScreen> {
  String? _selectedId; bool _constellation = true; late Future<List<ResonanceMapExperience>> _future;
  @override
  void initState() { super.initState(); _future = _resolve(); }
  Future<List<ResonanceMapExperience>> _resolve() {
    final spaces = ref.read(spaceProvider).asData?.value ?? const <Space>[];
    return ref.read(resonanceMapExperienceResolverProvider).resolve(experienceIds: widget.map.experienceIds, ventsById: widget.ventsById, spacesById: {for (final s in spaces) s.id: s});
  }
  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(resonanceMapThreadsProvider(widget.map.id));
    return Scaffold(backgroundColor: VentvoColors.background, appBar: AppBar(title: const Text('Explore landscape'), centerTitle: true), body: FutureBuilder<List<ResonanceMapExperience>>(future: _future, builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
      final experiences = snap.data ?? const <ResonanceMapExperience>[];
      ResonanceMapExperience? selected;
      for (final e in experiences) { if (e.id == _selectedId) selected = e; }
      return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 36), physics: const BouncingScrollPhysics(), children: [
        const Text('A LANDSCAPE OF EXPERIENCES', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 10), const Text('There are experiences around yours.', style: TextStyle(color: VentvoColors.textPrimary, fontSize: 23, fontWeight: FontWeight.w600, height: 1.25)),
        const SizedBox(height: 7), const Text('Wander through the connections that have taken shape. Your selection stays with you when you switch views.', style: TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.5)),
        const SizedBox(height: 18), SegmentedButton<bool>(segments: const [ButtonSegment(value: true, icon: Icon(Icons.auto_awesome_outlined), label: Text('Constellation')), ButtonSegment(value: false, icon: Icon(Icons.view_list_outlined), label: Text('Landscape'))], selected: {_constellation}, onSelectionChanged: (v) => setState(() => _constellation = v.first)),
        const SizedBox(height: 16), AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: _constellation ? Container(key: const ValueKey('sky'), height: 360, decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(25), border: Border.all(color: VentvoColors.border)), clipBehavior: Clip.antiAlias, child: _InteractiveMap(map: widget.map, experiences: experiences, selectedId: _selectedId, onSelect: (id) => setState(() => _selectedId = id))) : _ExperienceList(key: const ValueKey('list'), experiences: experiences, selectedId: _selectedId, onSelect: (id) => setState(() => _selectedId = id))),
        if (selected != null) ...[const SizedBox(height: 14), _SelectedExperience(experience: selected)],
        if (threadAsync.hasValue && threadAsync.value!.isNotEmpty) ...[const SizedBox(height: 22), _Threads(threads: threadAsync.value!, ventsById: widget.ventsById)],
      ]);
    }));
  }
}

class _InteractiveMap extends StatelessWidget {
 final ResonanceMap map; final List<ResonanceMapExperience> experiences; final String? selectedId; final ValueChanged<String> onSelect;
 const _InteractiveMap({required this.map, required this.experiences, required this.selectedId, required this.onSelect});
 @override Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) { final pts = _points(experiences.map((e) => e.id).toList(), Size(c.maxWidth,c.maxHeight)); return Stack(children: [Positioned.fill(child: CustomPaint(painter: _Painter(map,pts,selectedId))), for (final e in experiences) if (pts[e.id] != null) Positioned(left: pts[e.id]!.dx-34, top: pts[e.id]!.dy-34, width: 68, height: 68, child: InkWell(customBorder: const CircleBorder(), onTap: () => onSelect(e.id), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [AnimatedContainer(duration: const Duration(milliseconds: 180), width: e.id == selectedId ? 27:17, height: e.id == selectedId ? 27:17, decoration: BoxDecoration(shape: BoxShape.circle, color: e.id == selectedId ? VentvoColors.primary : VentvoColors.surfaceElevated, border: Border.all(color: VentvoColors.secondary.withValues(alpha:.7)), boxShadow: e.id == selectedId ? [BoxShadow(color: VentvoColors.primary.withValues(alpha:.28), blurRadius: 18, spreadRadius: 3)] : null)), const SizedBox(height: 5), Text(e.voiceMark, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VentvoColors.textSecondary,fontSize:9))]))))]); });
}

class _ExperienceList extends StatelessWidget {
 final List<ResonanceMapExperience> experiences; final String? selectedId; final ValueChanged<String> onSelect;
 const _ExperienceList({super.key, required this.experiences, required this.selectedId, required this.onSelect});
 @override Widget build(BuildContext context) => Column(children: [for (final e in experiences) Padding(padding: const EdgeInsets.only(bottom:10), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => onSelect(e.id), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: e.id == selectedId ? VentvoColors.surfaceElevated : VentvoColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: e.id == selectedId ? VentvoColors.primary.withValues(alpha:.5) : VentvoColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.isEcho ? 'ECHO' : 'MOMENT', style: const TextStyle(color: VentvoColors.textMuted,fontSize:8,fontWeight:FontWeight.w700,letterSpacing:1.2)), const SizedBox(height:7), Text(e.content, maxLines:4, overflow:TextOverflow.ellipsis, style: const TextStyle(color:VentvoColors.textPrimary,fontSize:14,height:1.5)), const SizedBox(height:8), Text(e.voiceMark, style: const TextStyle(color:VentvoColors.textMuted,fontSize:10))]))))]);
}

class _SelectedExperience extends StatelessWidget {
 final ResonanceMapExperience experience; const _SelectedExperience({required this.experience});
 @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: VentvoColors.surfaceElevated,borderRadius:BorderRadius.circular(20),border:Border.all(color:VentvoColors.border)), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children: [Text(experience.isEcho ? 'ECHO' : 'MOMENT',style:const TextStyle(color:VentvoColors.textMuted,fontSize:8,fontWeight:FontWeight.w700,letterSpacing:1.1)),const SizedBox(height:8),Text(experience.content,maxLines:5,overflow:TextOverflow.ellipsis,style:const TextStyle(color:VentvoColors.textPrimary,fontSize:14,height:1.55)),if(experience.space != null) Align(alignment:Alignment.centerRight,child:TextButton(onPressed:()=>SpaceScreen.open(context,experience.space!),child:const Text('Open Moment')))]));
}

class _Threads extends StatelessWidget {
 final List<ResonanceThread> threads; final Map<String,Vent> ventsById; const _Threads({required this.threads,required this.ventsById});
 @override Widget build(BuildContext context) => Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('PATHS THROUGH THIS LANDSCAPE',style:TextStyle(color:VentvoColors.textMuted,fontSize:8,fontWeight:FontWeight.w700,letterSpacing:1.4)),const SizedBox(height:10),for(final t in threads) Padding(padding:const EdgeInsets.only(bottom:9),child:InkWell(borderRadius:BorderRadius.circular(17),onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>ResonanceThreadDetailScreen(thread:t,ventsById:ventsById))),child:Container(padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:VentvoColors.surface,borderRadius:BorderRadius.circular(17),border:Border.all(color:VentvoColors.border)),child:Row(children:[const Icon(Icons.route_outlined,size:17,color:VentvoColors.textMuted),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${t.experienceIds.length} connected experiences',style:const TextStyle(color:VentvoColors.textPrimary,fontSize:13,fontWeight:FontWeight.w600)),const SizedBox(height:4),const Text('Explore this story',style:TextStyle(color:VentvoColors.textMuted,fontSize:11))])),const Icon(Icons.arrow_forward_rounded,size:16,color:VentvoColors.textMuted)]))))]);
}

class _Art extends StatelessWidget { final ResonanceMap map; const _Art({required this.map}); @override Widget build(BuildContext context)=>CustomPaint(painter:_Painter(map,_points(map.experienceIds,const Size(340,210)),null),child:const SizedBox.expand()); }
Map<String,Offset> _points(List<String> ids,Size size){if(ids.isEmpty)return const{};final c=Offset(size.width/2,size.height/2);if(ids.length==1)return{ids.first:c};final r=math.min(size.width,size.height)*.29;final a=math.pi*(3-math.sqrt(5));return{for(var i=0;i<ids.length;i++)ids[i]:i==0?c:Offset(c.dx+math.cos(-math.pi/2+(i-1)*a)*r,c.dy+math.sin(-math.pi/2+(i-1)*a)*r)};}
class _Painter extends CustomPainter {final ResonanceMap map;final Map<String,Offset> points;final String? selected;_Painter(this.map,this.points,this.selected);@override void paint(Canvas canvas,Size size){final center=Offset(size.width/2,size.height/2);canvas.drawCircle(center,math.min(size.width,size.height)*.3,Paint()..color=VentvoColors.primary.withValues(alpha:.045)..maskFilter=const MaskFilter.blur(BlurStyle.normal,50));for(final edge in map.connections){final a=points[edge.sourceId],b=points[edge.targetId];if(a==null||b==null)continue;final focus=selected!=null&&(edge.sourceId==selected||edge.targetId==selected);canvas.drawLine(a,b,Paint()..color=focus?VentvoColors.primary.withValues(alpha:.7):VentvoColors.secondary.withValues(alpha:.18)..strokeWidth=focus?1.6:.8..style=PaintingStyle.stroke);}final p=Paint()..color=VentvoColors.textMuted.withValues(alpha:.12);for(final f in const[Offset(.13,.2),Offset(.82,.18),Offset(.85,.75),Offset(.2,.82),Offset(.63,.88)]){canvas.drawCircle(Offset(size.width*f.dx,size.height*f.dy),1.3,p);}}@override bool shouldRepaint(covariant _Painter old)=>old.map.id!=map.id||old.map.connections.length!=map.connections.length||old.selected!=selected||old.points.length!=points.length;}
