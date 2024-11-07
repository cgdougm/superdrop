import 'package:flutter/material.dart';
import 'package:superdrop/my_draggable_widget.dart';
import 'types.dart';

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

  void updateDropPreview(PanelLocation update) =>
      setState(() => dropPreview = update);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // final gutters = widget.columns + 1;
        // final spaceForColumns = constraints.maxWidth - (gutters * widget.itemSpacing);
        // final columnWidth = spaceForColumns / widget.columns;
        // final itemWidth = Size(columnWidth, columnWidth);
        return Stack(
          children: <Widget>[
            Positioned(
              height: constraints.maxHeight / 2,
              width: constraints.maxWidth,
              top: 0,
              child: ItemPanel(
                crossAxisCount: widget.columns,
                items: upper,
                onDragStart: onDragStart,
                dragStart: dragStart?.panel == Panel.upper
                    ? dragStart
                    : null,
                panel: Panel.upper,
                spacing: widget.itemSpacing,
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
              child: ItemPanel(
                crossAxisCount: widget.columns,
                items: lower,
                onDragStart: onDragStart,
                dragStart: dragStart?.panel == Panel.lower
                    ? dragStart
                    : null,
                panel: Panel.lower,
                spacing: widget.itemSpacing,
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
    required this.items,
    required this.onDragStart,
    required this.panel,
    required this.spacing,
  });

  final int crossAxisCount;
  final PanelLocation? dragStart;
  final List<String> items;
  final double spacing;
  final Function(PanelLocation) onDragStart;
  final Panel panel;

  @override
  Widget build(BuildContext context) {
    PanelLocation? dragStartCopy;
    if (dragStart != null) {
      dragStartCopy = dragStart!.copyWith();
    }
    return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: items.asMap().entries.map<Widget>(
        (MapEntry<int, String> entry) {
          Color textColor = entry.key == dragStartCopy?.index
              ? Colors.black
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
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
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
