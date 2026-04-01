import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// When session becomes active on /auth or /register, go to [setPasswordRoute] or [homeRoute].
class PostLoginRedirect extends StatefulWidget {
  const PostLoginRedirect({super.key, required this.child});

  final Widget child;

  @override
  State<PostLoginRedirect> createState() => _PostLoginRedirectState();
}

class _PostLoginRedirectState extends State<PostLoginRedirect> {
  late final AuthProvider _auth;
  bool _didRedirect = false;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _auth.addListener(_onAuth);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuth());
  }

  void _onAuth() {
    if (!mounted) return;
    if (!_auth.isLoggedIn) {
      _didRedirect = false;
      return;
    }
    if (_didRedirect) return;
    _didRedirect = true;
    final nav = Navigator.of(context);
    if (_auth.needsEmailPasswordSetup) {
      nav.pushReplacementNamed('/set-password');
    } else {
      nav.pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuth);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
