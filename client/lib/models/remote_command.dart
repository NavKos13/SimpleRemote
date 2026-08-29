import 'dart:convert';

abstract class RemoteCommand {
  const RemoteCommand();

  Map<String, dynamic> toJson();

  String toJsonString() => jsonEncode(toJson());

  List<int> toUtf8Bytes() => utf8.encode(toJsonString());
}

class MouseMoveCommand extends RemoteCommand {
  final double dx;
  final double dy;

  const MouseMoveCommand({required this.dx, required this.dy});

  @override
  Map<String, dynamic> toJson() => {'type': 'mouseMove', 'dx': dx, 'dy': dy};
}

class MouseClickCommand extends RemoteCommand {
  final Button button;
  final Direction direction;

  const MouseClickCommand({required this.button, required this.direction});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mouseClick',
    'button': button.value,
    'direction': direction.value,
  };
}

enum Button {
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
  const Button(this.value);
}

enum Direction {
  press('Press'),
  release('Release'),
  click('Click');

  final String value;
  const Direction(this.value);
}
