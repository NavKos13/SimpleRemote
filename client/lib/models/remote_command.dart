import 'dart:convert';

import 'enums.dart';

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
  final MouseButton button;
  final Direction direction;

  const MouseClickCommand({required this.button, required this.direction});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mouseClick',
    'button': button.value,
    'direction': direction.value,
  };
}

class MouseScrollCommand extends RemoteCommand {
  final double scrollX;
  final double scrollY;

  const MouseScrollCommand({required this.scrollX, required this.scrollY});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mouseScroll',
    'dx': scrollX,
    'dy': scrollY,
  };
}

class TextInputCommand extends RemoteCommand {
  final String text;

  const TextInputCommand({required this.text});

  @override
  Map<String, dynamic> toJson() => {'type': 'keyPress', 'key': text};
}

class SpecialKeyPressCommand extends RemoteCommand {
  final SpecialKey key;
  final Direction direction;

  const SpecialKeyPressCommand({required this.key, required this.direction});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'specialKey',
    'key': key.value,
    'direction': direction.value,
  };
}
