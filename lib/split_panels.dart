import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:superdrop/my_draggable_widget.dart';
import 'package:superdrop/types.dart';
import 'package:superdrop/my_drop_region.dart';

class SplitPanels extends StatefulWidget {
  const SplitPanels({
    super.key,
    this.columns = 5,
    this.itemSpacing = 4.0,
  });

  final int columns;
  final double itemSpacing;

  @override
  State<SplitPanels> createState() => _SplitPanelsState();
}

class _SplitPanelsState extends State<SplitPanels> {
  final List<String> upper = [];
  final List<String> lower = List.generate(
      4, (index) => String.fromCharCode('A'.codeUnits[0] + index));

  PanelLocation? dragStart;
  PanelLocation? dropPreview;
  String? hoveringData;

  void onDragStart(PanelLocation start) {
    final data = switch (start.panel) {
      Panel.lower => lower[start.index],
      Panel.upper => upper[start.index],
    };
    setState(() {
      dragStart = start;
      hoveringData = data;
    });
  }

  void drop() {
    assert(dropPreview != null, 'Can only drop over a known location');
    assert(hoveringData != null, 'Can only drop when data is being dragged');
    setState(() {
      if (dragStart != null) {
        (dragStart!.panel == Panel.upper ? upper : lower)
            .removeAt(dragStart!.index);
      }
      if (dropPreview!.panel == Panel.upper) {
        upper.insert(min(dropPreview!.index, upper.length), hoveringData!);
      } else {
        lower.insert(min(dropPreview!.index, lower.length), hoveringData!);
      }
      dragStart = null;
      dropPreview = null;
      hoveringData = null;
    });
  }

  void setExternalData(String data) => setState(() => hoveringData = data);

  void updateDropPreview(PanelLocation update) =>
      setState(() => dropPreview = update);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutters = widget.columns + 1;
        final spaceForColumns =
            constraints.maxWidth - (gutters * widget.itemSpacing);
        final columnWidth = spaceForColumns / widget.columns;
        final itemSize = Size(columnWidth, columnWidth);
        return Stack(
          children: <Widget>[
            Positioned(
              height: constraints.maxHeight / 2,
              width: constraints.maxWidth,
              top: 0,
              child: MyDropRegion(
                onDrop: drop,
                setExternalData: setExternalData,
                updateDropPreview: updateDropPreview,
                childSize: itemSize,
                columns: widget.columns,
                panel: Panel.upper,
                child: ItemPanel(
                  crossAxisCount: widget.columns,
                  items: upper,
                  onDragStart: onDragStart,
                  dragStart: dragStart?.panel == Panel.upper ? dragStart : null,
                  dropPreview:
                      dropPreview?.panel == Panel.upper ? dropPreview : null,
                  hoveringData:
                      dropPreview?.panel == Panel.upper ? hoveringData : null,
                  panel: Panel.upper,
                  spacing: widget.itemSpacing,
                ),
              ),
            ),
            Positioned(
              height: 2,
              width: constraints.maxWidth,
              top: constraints.maxHeight / 2,
              child: const ColoredBox(
                color: Colors.black,
              ),
            ),
            Positioned(
              height: constraints.maxHeight / 2,
              width: constraints.maxWidth,
              bottom: 0,
              child: MyDropRegion(
                onDrop: drop,
                setExternalData: setExternalData,
                updateDropPreview: updateDropPreview,
                childSize: itemSize,
                columns: widget.columns,
                panel: Panel.lower,
                child: ItemPanel(
                  crossAxisCount: widget.columns,
                  items: lower,
                  onDragStart: onDragStart,
                  dragStart: dragStart?.panel == Panel.lower ? dragStart : null,
                  dropPreview:
                      dropPreview?.panel == Panel.lower ? dropPreview : null,
                  hoveringData:
                      dropPreview?.panel == Panel.lower ? hoveringData : null,
                  panel: Panel.lower,
                  spacing: widget.itemSpacing,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ItemPanel extends StatelessWidget {
  const ItemPanel({
    super.key,
    required this.crossAxisCount,
    required this.dragStart,
    required this.dropPreview,
    required this.hoveringData,
    required this.items,
    required this.onDragStart,
    required this.panel,
    required this.spacing,
  });

  final int crossAxisCount;
  final PanelLocation? dragStart;
  final PanelLocation? dropPreview;
  final String? hoveringData;
  final List<String> items;
  final double spacing;
  final Function(PanelLocation) onDragStart;
  final Panel panel;

  @override
  Widget build(BuildContext context) {
    final itemsCopy = List<String>.from(items);
    PanelLocation? dragStartCopy;
    PanelLocation? dropPreviewCopy;
    if (dragStart != null) {
      dragStartCopy = dragStart!.copyWith();
    }
    if (dropPreview != null) {
      dropPreviewCopy = dropPreview!.copyWith(
        index: min(items.length, dropPreview!.index),
      );
    }
    if (dragStartCopy != null &&
        dropPreviewCopy != null &&
        dragStartCopy.panel == dropPreviewCopy.panel) {
      itemsCopy.removeAt(dragStartCopy.index);
      dragStartCopy = null;
    }
    if (dropPreview != null && hoveringData != null) {
      itemsCopy.insert(
        min(dropPreview!.index, itemsCopy.length),
        hoveringData!,
      );
    }
    return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: itemsCopy.asMap().entries.map<Widget>(
        (MapEntry<int, String> entry) {
          Color textColor = entry.key == dragStartCopy?.index ||
                  entry.key == dropPreviewCopy?.index
              ? Colors.red
              : Colors.white;
          Widget child = Center(
            child: Text(
              entry.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: textColor),
            ),
          );

          if (entry.key == dragStartCopy?.index) {
            child = Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: child,
            );
          } else if (entry.key == dropPreviewCopy?.index) {
            child = DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(20),
              dashPattern: const [10, 10],
              color: Colors.grey,
              strokeWidth: 2,
              child: child,
            );
          } else {
            child = Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: child,
            );
          }
          return Draggable(
              feedback: child,
              child: MyDraggableWidget(
                  data: entry.value,
                  onDragStart: () => onDragStart((entry.key, panel)),
                  child: child));
        },
      ).toList(),
    );
  }
}
