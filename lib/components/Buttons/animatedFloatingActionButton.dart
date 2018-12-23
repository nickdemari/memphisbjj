import 'package:flutter/material.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  final Function() checkInToClass;
  final Function() addToSchedule;
  final Function() removeFromSchedule;
  final double meters;
  final bool onSchedule;
  final bool checkedIn;

  AnimatedFloatingActionButton({
    this.checkInToClass,
    this.addToSchedule,
    this.removeFromSchedule,
    this.meters,
    this.onSchedule,
    this.checkedIn
  });

  @override
  _AnimatedFloatingActionButtonState createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
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
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton.extended(
        heroTag: "add",
        onPressed: !widget.onSchedule ?  widget.addToSchedule : null,
        tooltip: 'Add',
        icon: Icon(Icons.add),
        label: Text("Add to schedule"),
        backgroundColor: widget.meters == null && !widget.onSchedule ? null : Colors.grey,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget checkIn() {
    return Container(
      child: FloatingActionButton.extended(
        heroTag: "image",
        onPressed: widget.meters != null || widget.onSchedule ? widget.checkInToClass : null,
        tooltip: 'Image',
        icon: Icon(Icons.check),
        label: Text("Check in to class"),
        backgroundColor: widget.meters != null || widget.onSchedule ? null : Colors.grey,
      ),
    );
  }

  Widget remove() {
    return Container(
      child: FloatingActionButton.extended(
        heroTag: "inbox",
        onPressed: widget.meters != null || (widget.onSchedule && !widget.checkedIn) ? widget.removeFromSchedule : null,
        tooltip: 'Inbox',
        icon: Icon(Icons.remove),
        label: Text("Remove from schedule"),
        backgroundColor: widget.meters != null || widget.onSchedule ? null : Colors.grey,
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: isOpened ? _renderTools() : _renderBlank(),
    );
  }

  List<Widget> _renderBlank() {
    return <Widget>[
      toggle()
    ];
  }

  List<Widget> _renderTools() {
    return <Widget>[
      Transform(
        transform: Matrix4.translationValues(
          0.0,
          _translateButton.value * 3.0,
          0.0,
        ),
        child: add(),
      ),
      Transform(
        transform: Matrix4.translationValues(
          0.0,
          _translateButton.value * 2.0,
          0.0,
        ),
        child: checkIn(),
      ),
      Transform(
        transform: Matrix4.translationValues(
          0.0,
          _translateButton.value,
          0.0,
        ),
        child: remove(),
      ),
      toggle()
    ];
  }
}
