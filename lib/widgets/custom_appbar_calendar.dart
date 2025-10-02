import 'package:flutter/material.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/enums/type_calendar.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';

class CustomAppBarCalendar extends StatefulWidget
    implements PreferredSizeWidget {
  final DateTime currentDate;
  final Function(int year, int month) onDateChange;
  const CustomAppBarCalendar({
    Key? key,
    required this.currentDate,
    required this.onDateChange,
  }) : super(key: key);

  @override
  _CustomAppBarCalendarState createState() => _CustomAppBarCalendarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarCalendarState extends State<CustomAppBarCalendar> {
  List<String> months = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  final ValueNotifier<_ButtomState?> _openMenu = ValueNotifier(null);

  TypeCalendar typeCalendar = TypeCalendar.MONTH;
  late String monthSelected;
  late int yearSelected;

  @override
  void initState() {
    super.initState();
    monthSelected = months[widget.currentDate.month - 1];
    yearSelected = widget.currentDate.year;
  }

  String getActualMonth() {
    DateTime now = DateTime.now();
    return months[now.month - 1];
  }

  List<int> getYearsInRange(int startYear, int endYear) {
    return List.generate(endYear - startYear + 1, (index) => startYear + index)
        .reversed
        .toList();
  }

  void _updateDate() {
    final monthIndex = months.indexOf(monthSelected) + 1;
    widget.onDateChange(DateTime(yearSelected, monthIndex).year,
        DateTime(yearSelected, monthIndex).month);
  }

  @override
  void didUpdateWidget(CustomAppBarCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDate != oldWidget.currentDate) {
      setState(() {
        monthSelected = months[widget.currentDate.month - 1];
        yearSelected = widget.currentDate.year;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: '',
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            child: Row(
              children: [
                _Buttom(
                  text: null,
                  height: 200,
                  controller: _openMenu,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            typeCalendar = TypeCalendar.DAY;
                          });
                          Navigator.of(context)
                              .pushNamed(AppRoutes.dayCalendar);
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/calendario-dia.png',
                              width: 30,
                              height: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                'Dia',
                                style: TextStyle(
                                  color: MainColor.primaryColor,
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          typeCalendar = TypeCalendar.WEEK;
                        });
                        Navigator.of(context).pushNamed(AppRoutes.weekCalendar);
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/calendario-semana.png',
                            width: 30,
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              'Semana',
                              style: TextStyle(
                                  color: MainColor.primaryColor, fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          typeCalendar = TypeCalendar.MONTH;
                        });
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/calendario-mes.png',
                            width: 30,
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              'Mês',
                              style: TextStyle(
                                  color: MainColor.primaryColor, fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                _Buttom(
                  text: monthSelected,
                  controller: _openMenu,
                  children: months.map((month) {
                    return ListTile(
                      title: Text(
                        month,
                        style: TextStyle(
                          color: MainColor.primaryColor,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          monthSelected = month;
                          _updateDate();
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        _Buttom(
          text: yearSelected.toString(),
          controller: _openMenu,
          children: getYearsInRange(2000, DateTime.now().year).map((year) {
            return ListTile(
              title: Text(
                year.toString(),
                style: TextStyle(
                  color: MainColor.primaryColor,
                ),
              ),
              onTap: () {
                setState(() {
                  yearSelected = year;
                  _updateDate();
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }
}

class _Buttom extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final List<Widget>? children;
  final double? height;
  final ValueNotifier<_ButtomState?> controller;

  const _Buttom(
      {Key? key,
      this.text,
      this.onPressed,
      this.children,
      this.height,
      required this.controller})
      : super(key: key);

  @override
  State<_Buttom> createState() => _ButtomState();
}

class _ButtomState extends State<_Buttom> {
  bool _isPressed = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showDropdown() {
    if (widget.controller.value != null && widget.controller.value != this) {
      widget.controller.value!._removeDropdown();
    }

    widget.controller.value = this;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
    }

    if (widget.controller.value == this) {
      widget.controller.value = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findAncestorRenderObjectOfType() as RenderBox;
    Size size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: _DropdownMenu(
            height: widget.height,
            children: widget.children ?? [],
            onClose: () {
              _removeDropdown();
              setState(() {
                _isPressed = false;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextButton(
        onPressed: () {
          setState(() {
            _isPressed = !_isPressed;
          });
          if (_isPressed) {
            _showDropdown();
          } else {
            _removeDropdown();
          }
        },
        child: widget.text != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.text ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Icon(
                    _isPressed ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              )
            : IconButton(
                onPressed: () {
                  setState(() {
                    _isPressed = !_isPressed;
                  });
                  if (_isPressed) {
                    _showDropdown();
                  } else {
                    _removeDropdown();
                  }
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 30,
                )),
      ),
    );
  }
}

class _DropdownMenu extends StatelessWidget {
  final List<Widget> children;
  final VoidCallback onClose;
  final double? height;

  const _DropdownMenu(
      {Key? key, required this.children, required this.onClose, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
      color: Colors.white,
      child: SizedBox(
        height: height ?? 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}
