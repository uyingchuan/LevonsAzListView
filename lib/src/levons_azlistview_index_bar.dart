import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class AzListIndexBar extends StatefulWidget {
  const AzListIndexBar({
    super.key,
    required this.parentKey,
    required this.symbols,
    this.onSelectionEnd,
    this.onSelectionUpdate,
  });

  final GlobalKey parentKey;

  final List<String> symbols;

  final void Function()? onSelectionEnd;

  final void Function(int index, Offset cursorOffset)? onSelectionUpdate;

  @override
  State<AzListIndexBar> createState() => _AzListIndexBarState();
}

class _AzListIndexBarState extends State<AzListIndexBar> {
  ListObserverController observerController = ListObserverController();

  double observeOffset = 0;

  ValueNotifier<int> selectedIndex = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onGestureHandler,
      onVerticalDragDown: _onGestureHandler,
      onVerticalDragCancel: _onGestureEnd,
      onVerticalDragEnd: _onGestureEnd,
      child: ListViewObserver(
        controller: observerController,
        dynamicLeadingOffset: () => observeOffset,
        child: _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return ValueListenableBuilder(
      valueListenable: selectedIndex,
      builder: (_, value, ___) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.symbols.length,
          itemBuilder: (_, index) {
            final isSelected = value == index;
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  widget.symbols[index],
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  _onGestureHandler(dynamic details) async {
    if (details is! DragUpdateDetails && details is! DragDownDetails) return;
    observeOffset = details.localPosition.dy;

    final result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
    );
    final observeResult = result.observeResult;
    if (observeResult == null) return;

    final firstChildModel = observeResult.firstChild;
    if (firstChildModel == null) return;
    final firstChildIndex = firstChildModel.index;
    selectedIndex.value = firstChildIndex;

    final firstChildRenderObj = firstChildModel.renderObject;
    final firstChildRenderObjOffset = firstChildRenderObj.localToGlobal(
      Offset.zero,
      ancestor: widget.parentKey.currentContext?.findRenderObject(),
    );
    final cursorOffset = Offset(
      firstChildRenderObjOffset.dx,
      firstChildRenderObjOffset.dy + firstChildModel.size.width * 0.5,
    );
    widget.onSelectionUpdate?.call(
      firstChildIndex,
      cursorOffset,
    );
  }

  _onGestureEnd([_]) {
    selectedIndex.value = -1;
    widget.onSelectionEnd?.call();
  }
}
