import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:superdrop/types.dart';
import 'dart:convert';

class MyDropRegion extends StatefulWidget {
  const MyDropRegion({
    super.key,
    required this.childSize,
    required this.columns,
    required this.panel,
    required this.onDrop,
    required this.setExternalData,
    required this.updateDropPreview,
    required this.child,
  });

  final Size childSize;
  final int columns;
  final Panel panel;
  final VoidCallback onDrop;
  final void Function(PanelLocation) updateDropPreview;
  final void Function(String) setExternalData;
  final Widget child;

  @override
  State<MyDropRegion> createState() => _MyDropRegionState();
}

class _MyDropRegionState extends State<MyDropRegion> {
  final List<DataFormat<Object>> formats = Formats.standardFormats;
  int? dropIndex;
  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: formats,
      onDropOver: (DropOverEvent event) {
        _updatePreview(event.position.local);
        return DropOperation.copy;
      },
      onPerformDrop: (PerformDropEvent event) async {
        widget.onDrop();
      },
      onDropEnter: (DropEvent event) {
        // TODO: iterate thru all event.session.items
        if (event.session.items.first.dataReader != null) {
          final dataReader = event.session.items.first.dataReader!;
          if (!dataReader.canProvide(Formats.plainTextFile)) {
            // TODO: Show "unsupported file type" SnackBar 
            // if any of the dropped files are not plain text
            return;
          }
          dataReader.getFile(
            Formats.plainTextFile,
            (value) async {
              widget.setExternalData(utf8.decode(await value.readAll()));
            },
          );
        }
      },
      child: widget.child,
    );
  }

  void _updatePreview(Offset hoverPosition) {
  final int row = hoverPosition.dy ~/ widget.childSize.height;
  final int column = (hoverPosition.dx - (widget.childSize.width / 2)) ~/
      widget.childSize.width;
    int newDropIndex = (row * widget.columns) + column;

    if (newDropIndex != dropIndex) {
      dropIndex = newDropIndex;
      widget.updateDropPreview((newDropIndex, widget.panel));
    }
  }
}
