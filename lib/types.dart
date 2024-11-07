enum Panel { upper, lower }

typedef PanelLocation = (int, Panel);

extension CopyablePanelLocation on PanelLocation {
  int get index => this.$1;
  Panel get panel => this.$2;
  PanelLocation copyWith({int? index, Panel? panel}) =>
      (index ?? this.index, panel ?? this.panel);
}
