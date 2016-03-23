part of rockdot_commons;

class RdSignal extends Event {
  final RdEventBus eventBus = new RdEventBus();

  dynamic _data;

  dynamic get data => _data;

  set data(dynamic data) {
    _data = data;
  }

  var _callback;

  get completeCallBack => _callback;

  RdSignal(String type, [this._data = null, this._callback = null]) : super(type);

  void dispatch() {
    eventBus.dispatchEvent(new RdSignal(type, _data, _callback));
  }

  void listen() {
    eventBus.addEventListener(type, _callback);
  }

  void unlisten() {
    eventBus.removeEventListener(type, _callback);
  }
}