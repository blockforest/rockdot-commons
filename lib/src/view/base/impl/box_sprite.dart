part of acanvas_commons;

class BoxSprite extends Sprite3D with MBox {
  BoxSprite() {}

  @override
  void span(spanWidth, spanHeight, {bool refresh: true}) {
    //if (this.spanWidth != spanWidth || this.spanHeight != spanHeight) {
    if (spanWidth > 0) this.spanWidth = spanWidth;
    if (spanHeight > 0) this.spanHeight = spanHeight;

    children
        .where((c) => c is MBox && (c as MBox).inheritSpan)
        .forEach((child) {
      (child as MBox).span(spanWidth, spanHeight, refresh: refresh);
    });
    children.where((c) => c is UITextField && c.inheritWidth).forEach((child) {
      child.width = spanWidth - 2 * padding;
    });

    //}
    if (refresh) {
      this.refresh();
    }
  }

  @override
  void refresh() {
    //adjust inherited span size to actual size
    if (autoSpan) {
      span(width, height, refresh: false);
    }
  }

  @override
  void dispose({bool removeSelf: true}) {
    //children.forEach doesn't work here, as dispose influences children<List>
    for (int i = 0; i < numChildren; i++) {
      disposeChild(getChildAt(i));
    }

    if (removeSelf && parent != null) {
      // keep parent from calling dispose again
      inheritDispose = false;
      // remove this sprite from parent
      parent.removeChild(this);
      // reactivate
      inheritDispose = true;
    }
  }

  void disposeChild(DisplayObject dobj) {
    if (dobj == null) return;

    if (dobj is MBox && (dobj as MBox).inheritDispose && dobj != this) {
      (dobj as MBox).dispose();
      return;
    }
    if (dobj.parent != null) {
      dobj.parent.removeChild(dobj);
    }
    if (dobj is Bitmap) {
      //dobj.bitmapData.clear();
    }
    if (dobj is BitmapData) {
      //(dobj as BitmapData).clear();
    }
    if (dobj is Shape) {
      dobj.graphics.clear();
    }
    if (dobj is Sprite) {
      dobj.graphics.clear();
    }
    dobj = null;
  }

  @override
  void addChild(DisplayObject child) {
    super.addChild(child);
    _addAcChild(child);
  }

  @override
  void addChildAt(DisplayObject child, int index) {
    super.addChildAt(child, index);
    _addAcChild(child);
  }

  void _addAcChild(DisplayObject child) {
    if (spanWidth > 0 &&
        spanHeight > 0 &&
        child is MBox &&
        (child as MBox).inheritSpan) {
      (child as MBox).span(spanWidth - 2 * padding, spanHeight, refresh: false);
    }

    if (child is MBox && (child as MBox).autoRefresh) {
      (child as MBox).refresh();
    }
  }

  @override
  void removeChild(DisplayObject child) {
    if (child is MBox && (child as MBox).inheritDispose) {
      (child as MBox).dispose();
    }
    super.removeChild(child);
  }
}
