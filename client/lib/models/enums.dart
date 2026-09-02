enum MouseButton {
  left('Left'),
  middle('Middle'),
  right('Right'),
  back('Back'),
  forward('Forward'),
  scrollUp('ScrollUp'),
  scrollDown('ScrollDown'),
  scrollLeft('ScrollLeft'),
  scrollRight('ScrollRight');

  final String value;
  const MouseButton(this.value);
}

enum Direction {
  press('Press'),
  release('Release'),
  click('Click');

  final String value;
  const Direction(this.value);
}

enum SpecialKey {
  // Modifiers
  control('Control'),
  alt('Alt'),
  shift('Shift'),
  meta('Meta'), // Windows key / Command on macOS

  // Navigation & Editing
  backspace('Backspace'),
  enter('Enter'),
  tab('Tab'),
  escape('Escape'),
  space('Space'),
  delete('Delete'),
  home('Home'),
  end('End'),
  pageUp('PageUp'),
  pageDown('PageDown'),

  // Arrows
  arrowUp('ArrowUp'),
  arrowDown('ArrowDown'),
  arrowLeft('ArrowLeft'),
  arrowRight('ArrowRight'),

  // Function Keys
  f1('F1'),
  f2('F2'),
  f3('F3'),
  f4('F4'),
  f5('F5'),
  f6('F6'),
  f7('F7'),
  f8('F8'),
  f9('F9'),
  f10('F10'),
  f11('F11'),
  f12('F12');

  final String value;
  const SpecialKey(this.value);
}
