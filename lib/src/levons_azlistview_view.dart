import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import 'levons_azlistview_cursor.dart';
import 'levons_azlistview_index_bar.dart';
import 'levons_azlistview_item_view.dart';

/// 用于生成azlistview的数据源
/// [section]为标签，A~Z
class AzListItem<T> {
  final String section;
  final List<T> names;

  AzListItem({
    required this.section,
    required this.names,
  });
}

class _AzListCursorInfo {
  final String title;
  final Offset offset;

  _AzListCursorInfo({
    required this.title,
    required this.offset,
  });
}

class LevonsAzListView extends StatefulWidget {
  const LevonsAzListView({super.key, required this.data});

  final List<AzListItem> data;

  @override
  State<LevonsAzListView> createState() => _LevonsAzListViewState();
}

class _LevonsAzListViewState extends State<LevonsAzListView> {
  late SliverObserverController observerController;
  ScrollController scrollController = ScrollController();

  final _indexBarKey = GlobalKey();

  List<String> get symbols => widget.data.map((e) => e.section).toList();

  final ValueNotifier<_AzListCursorInfo?> _cursorInfo = ValueNotifier(null);

  final double _indexBarWidth = 20;

  Map<int, BuildContext> sliverContextMap = {};

  @override
  initState() {
    super.initState();
    observerController = SliverObserverController(controller: scrollController);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // content list
        SliverViewObserver(
          controller: observerController,
          child: CustomScrollView(
            controller: scrollController,
            slivers: widget.data.mapIndexed((i, e) {
              return _buildSliver(i, e);
            }).toList(),
          ),
        ),

        // cursor indicate
        _buildCursor(),

        // A~Z index
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: _buildIndexBar(),
        ),
      ],
    );
  }

  Widget _buildSliver(int index, AzListItem item) {
    if (item.names.isEmpty) return const SliverToBoxAdapter();

    return SliverStickyHeader(
      header: Container(
        height: 44.0,
        color: const Color.fromARGB(255, 243, 244, 246),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Text(
          item.section,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, itemIndex) {
            if (sliverContextMap[index] == null) {
              sliverContextMap[index] = context;
            }
            return AzListItemView(name: item.names[itemIndex]);
          },
          childCount: item.names.length,
        ),
      ),
    );
  }

  Widget _buildCursor() {
    return ValueListenableBuilder<_AzListCursorInfo?>(
        valueListenable: _cursorInfo,
        builder: (_, value, ___) {
          if (value == null) return const SizedBox.shrink();

          double top = 0;
          double right = _indexBarWidth + 8;
          double titleSize = 80;
          top = value.offset.dy - titleSize * 0.5;
          return Positioned(
            top: top,
            right: right,
            child: AzListCursor(
              size: titleSize,
              title: value.title,
            ),
          );
        });
  }

  Widget _buildIndexBar() {
    return Container(
      key: _indexBarKey,
      width: _indexBarWidth,
      alignment: Alignment.center,
      child: AzListIndexBar(
        parentKey: _indexBarKey,
        symbols: symbols,
        onSelectionUpdate: (index, cursorOffset) {
          _cursorInfo.value = _AzListCursorInfo(
            title: symbols[index],
            offset: cursorOffset,
          );
          final sliverContext = sliverContextMap[index];
          if (sliverContext == null) return;
          observerController.jumpTo(
            index: 0,
            sliverContext: sliverContext,
          );
        },
        onSelectionEnd: () {
          _cursorInfo.value = null;
        },
      ),
    );
  }
}
