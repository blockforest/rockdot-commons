part of stagexl_commons;

class ImageSprite extends BoxSprite {
  Shape _background;

  BitmapData _bitmapData;

  void set bitmapData(BitmapData bitmapData) {
    _bitmapData = bitmapData;
    addChild(new Bitmap(_bitmapData));
    refresh();
    dispatchEvent(new Event(Event.COMPLETE));
  }

  void setBitmapData(BitmapData bitmapData) {
    this.bitmapData = bitmapData;
  }

  String _href;

  void set href(String href) {
    _href = href;
    var opts = new BitmapDataLoadOptions();
    opts.corsEnabled = true;
    BitmapData.load(_href, opts).then(setBitmapData).catchError(onIoError);
  }

  ImageSprite() : super() {
    _background = new Shape();
    addChild(_background);
  }

  void scaleToWidth(num w) {
    num scale;
    scale = w / _bitmapData.width;
    scaleX = scaleY = scale;
  }

  void scaleToHeight(num h) {
    num scale;
    scale = h / _bitmapData.height;
    scaleX = scaleY = scale;
  }

  @override
  void refresh() {

    if (spanWidth == 0 || spanHeight == 0) {
      return;
    }

    num scale;
    if (_bitmapData != null) {
      if (_bitmapData.width > _bitmapData.height) {
        scale = spanHeight / _bitmapData.height;
        if (_bitmapData.width * scale < spanWidth) {
          scale = spanWidth / _bitmapData.width;
        }
      } else {
        scale = spanWidth / _bitmapData.width;
        if (_bitmapData.height * scale < spanHeight) {
          scale = spanHeight / _bitmapData.height;
        }
      }
    }

    scaleX = scaleY = scale;

    // mask = new Mask.rectangle(0, 0, spanWidth, spanHeight)
    //   ..relativeToParent = true;

    super.refresh();
  }

  void onIoError(Error e) {
    this.logger.debug("IO error occured while loading image");
  }

}
