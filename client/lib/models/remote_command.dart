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
