import 'package:flutter/material.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  final Function() checkInToClass;
  final Function() addToSchedule;
  final Function() removeFromSchedule;
  final double meters;
  final bool onSchedule;
  final bool checkedIn;

  AnimatedFloatingActionButton({
    required this.checkInToClass,
    required this.addToSchedule,
    required this.removeFromSchedule,
    required this.meters,
    required this.onSchedule,
    required this.checkedIn,
  });

  @override
  _AnimatedFloatingActionButtonState createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _buttonColor;
  late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  bool isOpened = false;

  final double _fabHeight = 56.0;
  final Curve _curve = Curves.easeOut;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.75, curve: _curve),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void animate() {
    if (isOpened) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      isOpened = !isOpened;
    });
  }

  Widget _buildFloatingActionButton(
      {required Icon icon,
      required String label,
      required Color? backgroundColor,
      required VoidCallback? onPressed}) {
    return FloatingActionButton.extended(
      heroTag: label,
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      backgroundColor: backgroundColor,
    );
  }

  Widget add() {
    return _buildFloatingActionButton(
      icon: Icon(Icons.add),
      label: "SIGN UP",
      backgroundColor: (!widget.onSchedule && widget.meters != null)
          ? Colors.blue
          : Colors.grey,
      onPressed: !widget.onSchedule && widget.meters != null
          ? widget.addToSchedule
          : null,
    );
  }

  Widget checkIn() {
    return _buildFloatingActionButton(
      icon: Icon(Icons.check),
      label: "CHECK-IN",
      backgroundColor: (widget.meters != null && widget.onSchedule)
          ? Colors.blue
          : Colors.grey,
      onPressed: widget.meters != null && widget.onSchedule
          ? widget.checkInToClass
          : null,
    );
  }

  Widget remove() {
    return _buildFloatingActionButton(
      icon: Icon(Icons.remove),
      label: "CANCEL",
      backgroundColor:
          widget.onSchedule && !widget.checkedIn ? Colors.blue : Colors.grey,
      onPressed: widget.onSchedule && !widget.checkedIn
          ? widget.removeFromSchedule
          : null,
    );
  }

  Widget toggle() {
    return FloatingActionButton(
      backgroundColor: _buttonColor.value,
      onPressed: animate,
      tooltip: 'Toggle',
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _animateIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: isOpened ? _renderActionButtons() : [toggle()],
    );
  }

  List<Widget> _renderActionButtons() {
    return <Widget>[
      Transform(
        transform:
            Matrix4.translationValues(0.0, _translateButton.value * 3.0, 0.0),
        child: add(),
      ),
      Transform(
        transform:
            Matrix4.translationValues(0.0, _translateButton.value * 2.0, 0.0),
        child: checkIn(),
      ),
      Transform(
        transform: Matrix4.translationValues(0.0, _translateButton.value, 0.0),
        child: remove(),
      ),
      toggle(),
    ];
  }
}
