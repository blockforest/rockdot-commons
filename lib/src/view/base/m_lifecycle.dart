part of acanvas_commons;

/**
 * @author Nils Doehring (nilsdoehring@gmail.com)
 */
abstract class MLifecycle {
  static const double APPEAR_DURATION_DEFAULT = 0.0;
  static const double DISAPPEAR_DURATION_DEFAULT = 0.0;

  Map<String, String> _params = new Map();

  void set params(Map<String, String> params) {
    _params = params;
  }

  Map<String, String> get params => _params;

  bool _inheritInit = true;

  void set inheritInit(bool inheritInit) {
    _inheritInit = inheritInit;
  }

  bool get inheritInit => _inheritInit;

  bool _inheritAppear = true;

  void set inheritAppear(bool inheritAppear) {
    _inheritAppear = inheritAppear;
  }

  bool get inheritAppear => _inheritAppear;

  bool _inheritDisappear = true;

  void set inheritDisappear(bool inheritDisappear) {
    _inheritDisappear = inheritDisappear;
  }

  bool get inheritDisappear => _inheritDisappear;

  bool _initialized = false;

  void set initialized(bool initialized) {
    _initialized = initialized;
  }

  bool get initialized => _initialized;

  bool _requiresLoading = false;

  void set requiresLoading(bool requiresLoading) {
    _requiresLoading = requiresLoading;
  }

  bool get requiresLoading => _requiresLoading;

  void init({Map<String, String> params: null}) {
    this.params = params;
    dispatchEvent(new LifecycleEvent(LifecycleEvent.INIT_START));
  }

  void onInitComplete();

  Future load({Map params: null});

  void appear({double duration: APPEAR_DURATION_DEFAULT}) {
    //event appear
    Ac.JUGGLER.delayCall(() {
      dispatchEvent(new LifecycleEvent(LifecycleEvent.APPEAR_COMPLETE));
    }, duration);
  }

  void disappear(
      {double duration: DISAPPEAR_DURATION_DEFAULT, bool autoDispose: false}) {
    //event disappear
  }

  void dispatchEvent(Event event);
}
