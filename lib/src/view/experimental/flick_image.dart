part of acanvas_commons;

class ComponentFlickImage extends BoxSprite {
  static const String LEFT = "LEFT";
  static const String MIDDLE = "MIDDLE";
  static const String RIGHT = "RIGHT";

  Sprite _holder;
  List _data;
  int _currentIndex = 0;
  bool tweening = false;
  Timer _flickTimer;
  bool fadeChildren;

  ComponentFlickImage(List data,
      [int flickInterval = 0, this.fadeChildren = false])
      : super() {
    _data = data;

    _holder = new Sprite();
    addChild(_holder);

    Sprite dobj = _data[_currentIndex] as Sprite;

    //_holder.mask = new Mask.rectangle(0, 0, dobj.width, dobj.height + 50);

    _placeItem(dobj, MIDDLE);

    if (flickInterval > 0) {
      _flickTimer =
          new Timer.periodic(new Duration(milliseconds: flickInterval), next);
    }
  }

  void _placeItem(Sprite data, String position) {
    Sprite child;
    switch (position) {
      case LEFT:
        child = _holder.getChildAt(0) as Sprite;
        data.x = (child.x - data.width).toInt();
        _holder.addChildAt(data, 0);

        Ac.JUGGLER.addTween(data, 1)..animate.x.to(0);

        Ac.JUGGLER.addTween(child, 1)
          ..animate.x.to(child.width.toInt())
          ..onComplete =
              () => Function.apply(_onTweenComplete, <dynamic>[child]);

        if (fadeChildren) {
          for (int i = 0; i < data.numChildren; i++) {
            data.getChildAt(i).alpha = 0;
          }
          _fadeChildren(data, 1);
          _fadeChildren(child, 0);
        }
        tweening = true;
        break;
      case MIDDLE:
        _holder.addChildAt(data, 0);
        break;
      case RIGHT:
        child = _holder.getChildAt(0) as Sprite;
        data.x = (child.x + child.width).toInt();
        _holder.addChildAt(data, 0);

        Ac.JUGGLER.addTween(data, 1)..animate.x.to(0);

        Ac.JUGGLER.addTween(child, 1)
          ..animate.x.to(-child.width.toInt())
          ..onComplete =
              () => Function.apply(_onTweenComplete, <dynamic>[child]);

        if (fadeChildren) {
          for (int i = 0; i < data.numChildren; i++) {
            data.getChildAt(i).alpha = 0;
          }
          _fadeChildren(data, 1);
          _fadeChildren(child, 0);
        }

        tweening = true;
        break;
    }
  }

  void _onTweenComplete(DisplayObject child) {
    _holder.removeChild(child);
    tweening = false;
  }

  void next([Timer timer = null]) {
    if (tweening == true) {
      return;
    }

    if (++_currentIndex == _data.length) {
      _currentIndex = 0;
    }

    _placeItem(_data[_currentIndex] as Sprite, RIGHT);
  }

  void prev() {
    if (tweening == true) {
      return;
    }
    if (--_currentIndex == -1) {
      _currentIndex = _data.length - 1;
    }

    _placeItem(_data[_currentIndex] as Sprite, LEFT);
  }

  void gotoPage(int page) {
    if (page == _currentIndex) {
      return;
    }

    if (page < 0 || page > _data.length) {
      page = 0;
    }

    _currentIndex = page;
    _placeItem(_data[_currentIndex] as Sprite, LEFT);
  }

  @override
  void dispose({bool removeSelf: true}) {
    _flickTimer.cancel();
    super.dispose();
  }

  void _fadeChildren(Sprite data, int alph) {
    for (int i = 0; i < data.numChildren; i++) {
      Ac.JUGGLER.addTween(data.getChildAt(i), .3)
        ..animate.alpha.to(alph)
        ..delay = (i + alph) * .3;
    }
  }
}
