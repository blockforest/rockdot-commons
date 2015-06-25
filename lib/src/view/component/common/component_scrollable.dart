part of stagexl_commons;


/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
class ComponentScrollable extends SpriteComponent {
  // _onKeyDown (UP, DOWN, LEFT, RIGHT)
  int scrollStep = 10;
  //
  SpriteComponent _view;
  Scrollbar _scrollbar;
  Scrollbar _hScrollbar;
  Scrollbar _vScrollbar;
  bool _maskEnabled = true;
  void set maskEnabled(bool e) {_maskEnabled = e;}
  bool _bounce = false;
  bool _touchEnabled = false;
  bool _keyboardEnabled = false;
  bool _mouseWheelEnabled = false;
  bool _snapToPage = false;
  bool _hideScrollbarsOnIdle = false;
  // Zoom
  bool _doubleClickToZoom = false;
  bool _viewZoomed = false;
  num _zoomOutValue = 1;
  num _zoomInValue = 2;
  num _normalizedValueH = 0;
  num _normalizedValueV = 0;
  // Touch enabled
  bool _touching = false;
  num _mouseOffsetX = 0;
  num _mouseOffsetY = 0;
  // States
  String _orientation;
  bool _interaction = false;
  bool _changing = false;
  bool _interactionH = false;
  bool _changingH = false;
  bool _interactionV = false;
  bool _changingV = false;
  bool _bOrientationHorizontal = false;

  bool _queryActualChildWidth;
  bool _queryActualChildHeight;
  ComponentScrollable(/*String orientation, SpriteComponent view, Type scrollbarClass*/) {
  }
  
  void superConstructor(String orientation, SpriteComponent spriteComponent, Scrollbar scrollbar, {bool queryActualChildWidth: true, bool queryActualChildHeight: true}) {

    _orientation = orientation;
    _scrollbar = scrollbar;

    if (_orientation == Orientation.HORIZONTAL) {
      _bOrientationHorizontal = true;
    } else {
      _bOrientationHorizontal = false;
    }

    _queryActualChildWidth = queryActualChildWidth;
    _queryActualChildHeight = queryActualChildHeight;

    _addScrollbars();

    this.view = spriteComponent;
    keyboardEnabled = false;
    
  }

  void _addScrollbars() {
    // H
    if (_hScrollbar == null) {

      _hScrollbar = _scrollbar.clone(Orientation.HORIZONTAL, 0, widthAsSet);
      _hScrollbar.ignoreCallSetSize = false;
      _hScrollbar.y = heightAsSet.round();
      _hScrollbar.addEventListener(SliderEvent.VALUE_CHANGE, _onHScrollbarChange, useCapture: false, priority: 0);
      _hScrollbar.mouseWheelSensitivity = 10;
      _hScrollbar.addEventListener(SliderEvent.INTERACTION_START, _onScrollbarInteractionStart, useCapture: false, priority: 0);
      _hScrollbar.addEventListener(SliderEvent.INTERACTION_END, _onScrollbarInteractionEnd, useCapture: false, priority: 0);
      _hScrollbar.addEventListener(SliderEvent.CHANGE_START, _onScrollbarChangeStart, useCapture: false, priority: 0);
      _hScrollbar.addEventListener(SliderEvent.CHANGE_END, _onScrollbarChangeEnd, useCapture: false, priority: 0);
      super.addChildAt(_hScrollbar, 0);
    } else {
      _hScrollbar.maxValue = _view.width - widthAsSet;
      print("[ScrollView] WARNING: ScrollbarH already created.");
    }

    // V
    if (_vScrollbar == null) {
      _vScrollbar = _scrollbar.clone(Orientation.VERTICAL, 0, heightAsSet);
      _vScrollbar.ignoreCallSetSize = false;
      _vScrollbar.x = widthAsSet.round();
      _vScrollbar.addEventListener(SliderEvent.VALUE_CHANGE, _onVScrollbarChange, useCapture: false, priority: 0);
      _vScrollbar.mouseWheelSensitivity = 10;
      _vScrollbar.addEventListener(SliderEvent.INTERACTION_START, _onScrollbarInteractionStart, useCapture: false, priority: 0);
      _vScrollbar.addEventListener(SliderEvent.INTERACTION_END, _onScrollbarInteractionEnd, useCapture: false, priority: 0);
      _vScrollbar.addEventListener(SliderEvent.CHANGE_START, _onScrollbarChangeStart, useCapture: false, priority: 0);
      _vScrollbar.addEventListener(SliderEvent.CHANGE_END, _onScrollbarChangeEnd, useCapture: false, priority: 0);
      super.addChildAt(_vScrollbar, 1);
    } else {
      _vScrollbar.maxValue = _view.height - heightAsSet;
      print("[ScrollView] WARNING: ScrollbarV already created.");
    }
  }

  void _onScrollbarInteractionStart(SliderEvent event) {
    if (event.target == _hScrollbar) _interactionH = true; else _interactionV = true;
    interactionStart();
  }

  void _onScrollbarInteractionEnd(SliderEvent event) {
    if (event.target == _hScrollbar) _interactionH = false; else _interactionV = false;
    if (!_interactionH && !_interactionV) interactionEnd();
  }

  void _onScrollbarChangeStart(SliderEvent event) {
    if (event.target == _hScrollbar) _changingH = true; else _changingV = true;
    changeStart();
  }

  void _onScrollbarChangeEnd(SliderEvent event) {
    if (event.target == _hScrollbar) _changingH = false; else _changingV = false;
    if (!_changingH && !_changingV) changeEnd();
  }

  void interactionStart() {
    if (!_interaction) {
      _interaction = true;
      dispatchEvent(new ScrollViewEvent(ScrollViewEvent.INTERACTION_START));
    }
  }

  void interactionEnd() {
    if (_interaction) {
      _interaction = false;
      dispatchEvent(new ScrollViewEvent(ScrollViewEvent.INTERACTION_END));
    }
  }

  void changeStart() {
    if (!_changing) {
      _changing = true;
      if (_hideScrollbarsOnIdle) {
        if (_hScrollbar.enabled) ContextTool.JUGGLER.addTween(_hScrollbar, 0.2)..animate.alpha.to(1);
        if (_vScrollbar.enabled) ContextTool.JUGGLER.addTween(_vScrollbar, 0.2)..animate.alpha.to(1);
      }
      dispatchEvent(new ScrollViewEvent(ScrollViewEvent.CHANGE_START));
    }
  }

  void changeEnd() {
    if (_changing) {
      _changing = false;
      if (_hideScrollbarsOnIdle) {
        if (_hScrollbar.enabled) ContextTool.JUGGLER.addTween(_hScrollbar, 0.2)..animate.alpha.to(0);
        if (_vScrollbar.enabled) ContextTool.JUGGLER.addTween(_vScrollbar, 0.2)..animate.alpha.to(0);
      }
      dispatchEvent(new ScrollViewEvent(ScrollViewEvent.CHANGE_END));
    }
  }

  void updateScrollbars() {
    num w = _queryActualChildWidth || _view.widthAsSet == 0 ? _view.width : _view.widthAsSet;
    num h = _queryActualChildHeight || _view.heightAsSet == 0 ? _view.height :  _view.heightAsSet;

    _hScrollbar.enabled = w > widthAsSet;
    _hScrollbar.maxValue = w - widthAsSet;

    _vScrollbar.enabled = h > heightAsSet;
    _vScrollbar.maxValue = h - heightAsSet;
    _updateThumbs();
  }

  void _updateThumbs() {
    num w = _queryActualChildWidth || _view.widthAsSet == 0 ? _view.width : _view.widthAsSet;
    num h = _queryActualChildHeight || _view.heightAsSet == 0 ? _view.height :  _view.heightAsSet;
    _hScrollbar.pages = w / widthAsSet;
    _vScrollbar.pages = h / heightAsSet;
  }

  SpriteComponent get view {
    return _view;
  }

  void set view(SpriteComponent vw) {
    if (vw != _view) {
      clearMomentum();
      if (_view != null) removeChild(_view);
      _view = vw;
      _view.doubleClickEnabled = _doubleClickToZoom;
      touchEnabled = _touchEnabled;
      doubleClickToZoom = _doubleClickToZoom;
      super.addChildAt(_view, 0);
      if (enabled) {
        updateScrollbars();
      }
      _hScrollbar.value = _vScrollbar.value = 0;
    }
  }

  bool get keyboardEnabled {
    return _keyboardEnabled;
  }

  void set keyboardEnabled(bool value) {
    if(_keyboardEnabled == value) return;
    _keyboardEnabled = value;
    if (_keyboardEnabled) addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, useCapture: false, priority: 0); else removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
  }

  void _onKeyDown(KeyboardEvent event) {
    switch (event.keyCode) {
      case Keyboard.UP:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.interactionStart(true, false);
          _vScrollbar.value -= scrollStep;
          _vScrollbar.interactionEnd();
        }
        break;
      case Keyboard.DOWN:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.interactionStart(true, false);
          _vScrollbar.value += scrollStep;
          _vScrollbar.interactionEnd();
        }
        break;
      case Keyboard.LEFT:
        if (_hScrollbar.enabled) {
          clearMomentum();
          _hScrollbar.interactionStart(true, false);
          _hScrollbar.value -= scrollStep;
          _hScrollbar.interactionEnd();
        }
        break;
      case Keyboard.RIGHT:
        if (_hScrollbar.enabled) {
          clearMomentum();
          _hScrollbar.interactionStart(true, false);
          _hScrollbar.value += scrollStep;
          _hScrollbar.interactionEnd();
        }
        break;
      case Keyboard.SPACE:
        if (_vScrollbar.enabled) {
          clearMomentum();
          if (!event.shiftKey) _vScrollbar.pageDown(); else _vScrollbar.pageUp();
        }
        break;
      case Keyboard.PAGE_DOWN:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.pageDown();
        }
        break;
      case Keyboard.PAGE_UP:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.pageUp();
        }
        break;
      case Keyboard.HOME:
        Scrollbar scroller = _bOrientationHorizontal ? _hScrollbar : _vScrollbar;
        if (scroller.enabled) {
          scroller.killPageTween();
          clearMomentum();
          scroller.scrollToPage(0);
        }
        break;
      case Keyboard.END:
        Scrollbar scroller = _bOrientationHorizontal ? _hScrollbar : _vScrollbar;
        if (scroller.enabled) {
          scroller.killPageTween();
          clearMomentum();
          scroller.scrollToPage(scroller.pages, 0, true);
        }
        break;
      default:
    }
  }

  bool get mouseWheelEnabled {
    return _mouseWheelEnabled;
  }

  void set mouseWheelEnabled(bool value) {
    _mouseWheelEnabled = value;
    if (_mouseWheelEnabled) addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel, useCapture: false, priority: 0); else removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
  }

  void _onMouseWheel(MouseEvent event) {
    clearMomentum();
    if (event.shiftKey) {
      if (_hScrollbar.enabled) _hScrollbar._onMouseWheel(event); else if (_vScrollbar.enabled) _vScrollbar._onMouseWheel(event);
    } else {
      if (_vScrollbar.enabled) _vScrollbar._onMouseWheel(event); else if (_hScrollbar.enabled) _hScrollbar._onMouseWheel(event);
    }
  }

  void _onHScrollbarChange(SliderEvent event) {
    _view.x = -event.value;
  }

  void _onVScrollbarChange(SliderEvent event) {
    _view.y = -event.value;
  }

  Scrollbar get hScrollbar {
    return _hScrollbar;
  }

  Scrollbar get vScrollbar {
    return _vScrollbar;
  }

  @override
  void set enabled(bool value) {
    if (value != _enabled) {
      super.enabled = value;
      if (_enabled) {
        keyboardEnabled = _keyboardEnabled;
        mouseWheelEnabled = _mouseWheelEnabled;
        updateScrollbars();
      } else {
        removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
        removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
      }
    }
  }

  @override
  void redraw() {
    _hScrollbar.y = heightAsSet - _hScrollbar.height;
    _vScrollbar.x = widthAsSet - _vScrollbar.width;
    
    if(_maskEnabled == true && _view != null){
      _view.mask = new Mask.rectangle(0, 0, widthAsSet, heightAsSet)..relativeToParent = true;
    }
          
    updateScrollbars();
  }

  bool get bounce {
    return _bounce;
  }

  void set bounce(bool value) {
    if (value != _bounce) _bounce = _hScrollbar.bounce = _vScrollbar.bounce = value;
  }

  bool get snapToPage {
    return _snapToPage;
  }

  void set snapToPage(bool value) {
    if (value != _snapToPage) _snapToPage = _hScrollbar.snapToPage = _vScrollbar.snapToPage = value;
  }

  bool get doubleClickToZoom {
    return _doubleClickToZoom;
  }

  void set doubleClickToZoom(bool value) {
    _doubleClickToZoom = _view.doubleClickEnabled = value;
    if (_doubleClickToZoom) _view.addEventListener(MouseEvent.DOUBLE_CLICK, _onViewDoubleClick, useCapture: false, priority: 0); else _view.removeEventListener(MouseEvent.DOUBLE_CLICK, _onViewDoubleClick);
  }

  void _onViewDoubleClick(MouseEvent event) {
    zoom(_viewZoomed ? _zoomOutValue : _zoomInValue, event.localX, event.localY);
    _viewZoomed = !_viewZoomed;
  }

  void zoom(num scale, num xPos, num yPos) {
    if (_hScrollbar.enabled) _normalizedValueH = _hScrollbar.value / _hScrollbar.maxValue;
    if (_vScrollbar.enabled) _normalizedValueV = _vScrollbar.value / _vScrollbar.maxValue;

    interactionStart();
    changeStart();

    _normalizedValueH = (xPos - widthAsSet / (2 * scale)) / ((_view.width / _view.scaleX) - widthAsSet / scale);
    _normalizedValueV = (yPos - heightAsSet / (2 * scale)) / ((_view.height / _view.scaleY) - heightAsSet / scale);


    ContextTool.JUGGLER.addTween(_view, 0.3)
        ..animate.scaleX.to(scale)
        ..animate.scaleY.to(scale)
        ..onUpdate = (() => _keepPos)
        ..onComplete = (() => _onZoomConplete);


    interactionEnd();
  }

  num get zoomInValue {
    return _zoomInValue;
  }

  void set zoomInValue(num zoomInValue) {
    _zoomInValue = zoomInValue;
  }

  void _keepPos() {
    updateScrollbars();

    int valH = _normalizedValueH * _hScrollbar.maxValue;
    if (valH < 0) valH = 0; else if (valH > _hScrollbar.maxValue) valH = _hScrollbar.maxValue;

    int valV = _normalizedValueV * _vScrollbar.maxValue;
    if (valV < 0) valV = 0; else if (valV > _vScrollbar.maxValue) valV = _vScrollbar.maxValue;

    _hScrollbar.value = valH;
    _vScrollbar.value = valV;
  }

  void _onZoomConplete() {
    changeEnd();
  }

  bool get touchEnabled {
    return _touchEnabled;
  }

  void set touchEnabled(bool value) {
    _touchEnabled = value;

    _hScrollbar.momentumEnabled = _touchEnabled;
    _vScrollbar.momentumEnabled = _touchEnabled;
    if (_touchEnabled) _view.addEventListener(MouseEvent.MOUSE_DOWN, _onViewMouseDown, useCapture: false, priority: 0); 
    else _view.removeEventListener(MouseEvent.MOUSE_DOWN, _onViewMouseDown);
  }

  void _onViewMouseDown(MouseEvent event) {
    _touching = true;
    if (_hScrollbar.enabled) _hScrollbar.interactionStart(false, false);
    if (_vScrollbar.enabled) _vScrollbar.interactionStart(false, false);
    _mouseOffsetX = stage.mouseX - _view.x;
    _mouseOffsetY = stage.mouseY - _view.y;
    stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp, useCapture: false, priority: 0);
    stage.addEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove, useCapture: false, priority: 0);
  }

  void _onStageMouseUp(MouseEvent event) {
    _touching = false;
    if (_hScrollbar.enabled) _hScrollbar.interactionEnd();
    if (_vScrollbar.enabled) _vScrollbar.interactionEnd();
    if (stage != null) {
      stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
    }
  }

  void clearMomentum() {
    _hScrollbar.clearMomentum();
    _vScrollbar.clearMomentum();
  }

  void _onStageMouseMove(MouseEvent event) {
    if (_hScrollbar.enabled) _hScrollbar.value = _mouseOffsetX - stage.mouseX;
    if (_vScrollbar.enabled) _vScrollbar.value = _mouseOffsetY - stage.mouseY;
    // event.updateAfterEvent();
  }

  num get zoomOutValue {
    return _zoomOutValue;
  }

  void set zoomOutValue(num zoomOutValue) {
    _zoomOutValue = zoomOutValue;
  }

  bool get hideScrollbarsOnIdle {
    return _hideScrollbarsOnIdle;
  }

  void set hideScrollbarsOnIdle(bool value) {
    _hideScrollbarsOnIdle = value;
    if (_hScrollbar.enabled) {
      ContextTool.JUGGLER.addTween(_hScrollbar, 0.2)..animate.alpha.to(_hideScrollbarsOnIdle ? 0 : 1);
    }
    if (_vScrollbar.enabled) {
      ContextTool.JUGGLER.addTween(_vScrollbar, 0.2)..animate.alpha.to(_hideScrollbarsOnIdle ? 0 : 1);
    }
  }
}
