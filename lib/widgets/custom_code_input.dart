import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomCodeInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? fieldName;

  const CustomCodeInput({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.fieldName,
    this.validator,
  }) : super(key: key);

  @override
  _CustomCodeInputState createState() => _CustomCodeInputState();
}

class _CustomCodeInputState extends State<CustomCodeInput> {
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (index == 5 && _controllers[5].text.isNotEmpty && value.isNotEmpty) {
      _controllers[5].text = _controllers[5].text;
      widget.controller.text = _controllers.map((c) => c.text).join();
      widget.onChanged?.call(widget.controller.text);
      return;
    }

    if (value.isNotEmpty && index < 5) {
      Future.delayed(Duration(milliseconds: 70), () {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      });
    }

    widget.controller.text = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(widget.controller.text);
  }

  void _handlePaste(String pastedText, int focusedIndex) {
      if (pastedText.length >= 6) {
        final code = pastedText.substring(0, 6);
        
        Future.microtask(() {
          for (int i = 0; i < 6; i++) {
            _controllers[i].text = code[i];
            
            if (mounted) setState(() {});
          }
          
          widget.controller.text = code;
          widget.onChanged?.call(code);
          FocusScope.of(context).requestFocus(_focusNodes[5]);
        });
      }
    }

  Future<void> _handleGlobalPaste() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text != null && clipboardData!.text!.length == 6) {
      _handlePaste(clipboardData.text!, 0);
    }
  }

  KeyEventResult _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 3; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: SizedBox(
                width: 50,
                height: 50,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyEvent(event, i),
                  child: FormBuilderTextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CodeInputFormatter(_handlePaste, i, _controllers),
                    ],
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                    ),
                    onChanged: (value) => _onChanged(value!, i),
                    name: '${widget.fieldName}_$i',
                  ),
                ),
              ),
            ),
          ),
   
        for (int i = 3; i < 6; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: SizedBox(
                width: 50,
                height: 50,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyEvent(event, i),
                  child: FormBuilderTextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CodeInputFormatter(_handlePaste, i, _controllers),
                    ],
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white, width: 3.0),
                      ),
                    ),
                    onChanged: (value) => _onChanged(value!, i),
                    name: '${widget.fieldName}_$i',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CodeInputFormatter extends TextInputFormatter {
  final Function(String, int) onPaste;
  final int focusedIndex;
  final List<TextEditingController> controllers;
  _CodeInputFormatter(this.onPaste, this.focusedIndex, this.controllers);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (focusedIndex == 5 && controllers[5].text.isNotEmpty && newValue.text.isNotEmpty) {
      return oldValue;
    }

    if (newValue.text.length > 1) {
      onPaste(newValue.text, focusedIndex);
      return TextEditingValue.empty;
    }
    return newValue;
  }
}