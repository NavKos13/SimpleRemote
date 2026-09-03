import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart' hide Direction;
import '../models/remote_command.dart';
import '../models/enums.dart';
import '../services/tcp_service.dart';

class RemoteKeyboardSheet extends StatefulWidget {
  final TcpService tcpService;

  const RemoteKeyboardSheet({required this.tcpService});

  @override
  State<StatefulWidget> createState() => _RemoteKeyboardSheetState();
}

class _RemoteKeyboardSheetState extends State<RemoteKeyboardSheet> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Sticky modifier states
  bool _isCtrl = false;
  bool _isAlt = false;
  bool _isShift = false;
  bool _isMeta = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _releaseActiveModifiers();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _releaseActiveModifiers() {
    if (_isCtrl) _sendSpecialKey(SpecialKey.control, Direction.release);
    if (_isAlt) _sendSpecialKey(SpecialKey.alt, Direction.release);
    if (_isShift) _sendSpecialKey(SpecialKey.shift, Direction.release);
    if (_isMeta) _sendSpecialKey(SpecialKey.meta, Direction.release);
  }

  void _sendSpecialKey(SpecialKey key, Direction direction) {
    widget.tcpService.sendCommand(
      SpecialKeyPressCommand(key: key, direction: direction),
    );
  }

  void _toggleModifier(
    SpecialKey key,
    bool currentState,
    ValueSetter<bool> update,
  ) {
    final nextState = !currentState;
    update(nextState);
    _sendSpecialKey(key, nextState ? Direction.press : Direction.release);
    _focusNode.requestFocus();
  }

  void _sendSingleClickKey(SpecialKey key) {
    _sendSpecialKey(key, Direction.click);
    _focusNode.requestFocus();
  }

  void _onTextChanged(String value) {
    if (value.isEmpty) return;

    widget.tcpService.sendCommand(TextInputCommand(text: value));
    _textController.clear();

    if (_isCtrl || _isAlt || _isMeta || _isShift) {
      setState(() {
        _releaseActiveModifiers();
        _isCtrl = false;
        _isAlt = false;
        _isMeta = false;
        _isShift = false;
      });
    }
  }

  Widget _buildModifierButton({
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return ShadButton.raw(
      size: ShadButtonSize.sm,
      variant: isActive ? ShadButtonVariant.primary : ShadButtonVariant.outline,
      onPressed: onPressed,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadSheet(
      title: Text('Modifiers'),
      description: const Text(
        'Type to stream inputs; tap buttons for desktop keys.',
      ),
      actions: [
        ShadButton.ghost(
          size: ShadButtonSize.sm,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShadInput(
            controller: _textController,
            focusNode: _focusNode,
            placeholder: const Text(
              'Tap here and use native keyboard to stream...',
            ),
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: _onTextChanged,
          ),
          const SizedBox(height: 12.0),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildModifierButton(
                label: 'Ctrl',
                isActive: _isCtrl,
                onPressed: () => _toggleModifier(
                  SpecialKey.control,
                  _isCtrl,
                  (v) => setState(() {
                    _isCtrl = v;
                  }),
                ),
              ),
              _buildModifierButton(
                label: 'Alt',
                isActive: _isAlt,
                onPressed: () => _toggleModifier(
                  SpecialKey.alt,
                  _isAlt,
                  (v) => setState(() {
                    _isAlt = v;
                  }),
                ),
              ),
              _buildModifierButton(
                label: 'Win/Cmd',
                isActive: _isMeta,
                onPressed: () => _toggleModifier(
                  SpecialKey.meta,
                  _isMeta,
                  (v) => setState(() {
                    _isMeta = v;
                  }),
                ),
              ),
              _buildModifierButton(
                label: 'Shift',
                isActive: _isShift,
                onPressed: () => _toggleModifier(
                  SpecialKey.shift,
                  _isShift,
                  (v) => setState(() {
                    _isShift = v;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: () => _sendSingleClickKey(SpecialKey.escape),
                child: const Text('Esc'),
              ),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: () => _sendSingleClickKey(SpecialKey.tab),
                child: const Text('Tab'),
              ),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: () => _sendSingleClickKey(SpecialKey.backspace),
                child: const Text('⌫ Backspace'),
              ),
              ShadButton.outline(
                size: ShadButtonSize.sm,
                onPressed: () => _sendSingleClickKey(SpecialKey.enter),
                child: const Text('↵ Enter'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
