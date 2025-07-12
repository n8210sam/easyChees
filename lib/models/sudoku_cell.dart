class SudokuCell {
  int value;
  bool isFixed;
  bool isHighlighted;
  Set<int> notes;

  SudokuCell({
    this.value = 0,
    this.isFixed = false,
    this.isHighlighted = false,
    Set<int>? notes,
  }) : notes = notes ?? <int>{};

  SudokuCell copyWith({
    int? value,
    bool? isFixed,
    bool? isHighlighted,
    Set<int>? notes,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      isFixed: isFixed ?? this.isFixed,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      notes: notes ?? Set<int>.from(this.notes),
    );
  }

  bool get isEmpty => value == 0;
  bool get isNotEmpty => value != 0;

  @override
  String toString() {
    return 'SudokuCell(value: $value, isFixed: $isFixed)';
  }
}
