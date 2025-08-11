import 'package:flutter/material.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

abstract class LifeCycleState<T extends StatefulWidget> extends State<T>  with WidgetsBindingObserver
,
    RouteAware
{
  bool _isResumed = false;
  bool _wasStopped = false;





  /// Called once when the widget is inserted into the tree.
  @mustCallSuper
  @override
  void initState() {
    super.initState();



    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_){
      _onCreate?.call();
      _onResume?.call();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // AppUtils.log('state effect..... ${state}');
    if (state == AppLifecycleState.resumed) {
      if (_wasStopped) {
        _wasStopped = false;
        _onRestart?.call();
      }
      _onResume?.call();
    } else if (state == AppLifecycleState.paused) {
      _onPause?.call();
      _onStop?.call();
      _wasStopped = true;
    }else if(state == AppLifecycleState.detached){
      _onDetached?.call();
    }else if(state == AppLifecycleState.hidden){
      _onHidden?.call();
    }else if(state == AppLifecycleState.inactive){
      _onInactive?.call();
    }
  }

  @protected
  void lifeCycleEvents({
    Function()? onCreate,
    Function()? onRestart,
    Function()? onResume,
    Function()? onPause,
    Function()? onStop,
    Function()? onDetached,
    Function()? onHidden,
    Function()? onInactive,
  }){
    this._onCreate = onCreate;
    this._onRestart = onRestart;
    this._onResume = onResume;
    this._onPause = onPause;
    this._onStop = onStop;
    this._onDetached = onDetached;
    this._onHidden = onHidden;
    this._onInactive = onInactive;
  }


  /// Equivalent of Android's onResume
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isResumed) {
      _isResumed = true;
      _onResume?.call();
    }

    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }





  /// Called when the widget is paused or removed
  @override
  void deactivate() {
    _onPause?.call();
    _wasStopped = true;
    super.deactivate();
  }

  @override
  void didPopNext() {
    _onResume?.call();
    super.didPopNext();

  }

  /// Called when the widget is destroyed
  @override
  void dispose() {
    _onDestroy?.call();
    _onDetached?.call();
    // AppUtils.log('dispose');
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Function()? _onPause;

  Function()? _onStop;

  Function()? _onRestart;

  /// Equivalent of Android's onCreate
  Function()? _onCreate;

  /// Called when app is inactive (e.g., incoming call, control center opened)
  Function()?  _onInactive;

  /// Called when app is removed from view or closed
  Function()?  _onDetached;

  Function()? _onResume;


  /// Called when the app is hidden on desktop/web
  Function()? _onHidden;

  Function()? _onDestroy;
}
