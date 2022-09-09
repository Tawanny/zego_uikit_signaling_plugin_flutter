// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Project imports:
import 'package:zego_uikit_signal_plugin/src/services/services.dart';
import 'internal/page_manager.dart';
import 'prebuilt_call_invitation_defines.dart';

typedef ConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
    ZegoCallInvitationData);

class ZegoUIKitPrebuiltCallWithInvitation extends StatefulWidget {
  const ZegoUIKitPrebuiltCallWithInvitation({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    this.tokenServerUrl = '',
    required this.requireConfig,
    required this.child,
  }) : super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appSign you obtained from console.zegocloud.com
  final String appSign;

  /// tokenServerUrl is only for web.
  /// If you have to support Web and Android, iOS, then you can use it like this
  /// ```
  ///   ZegoUIKitPrebuiltCallWithInvitationConfig(
  ///     appID: appID,
  ///     userID: userID,
  ///     userName: userName,
  ///     appSign: kIsWeb ? '' : appSign,
  ///     tokenServerUrl: kIsWeb ? tokenServerUrl：'',
  ///   );
  /// ```
  final String tokenServerUrl;

  /// local user info
  final String userID;
  final String userName;

  ///
  final ConfigQuery requireConfig;

  final Widget child;

  @override
  State<ZegoUIKitPrebuiltCallWithInvitation> createState() =>
      _ZegoUIKitPrebuiltCallWithInvitationState();
}

class _ZegoUIKitPrebuiltCallWithInvitationState
    extends State<ZegoUIKitPrebuiltCallWithInvitation> {
  @override
  void initState() {
    super.initState();

    initContext();
  }

  @override
  void didUpdateWidget(ZegoUIKitPrebuiltCallWithInvitation oldWidget) {
    super.didUpdateWidget(oldWidget);

    reLoginContext(widget.userID, widget.userName);
  }

  @override
  void dispose() async {
    super.dispose();

    uninitContext();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void initContext() async {
    await ZegoSignalPlugin()
        .loadZim(appID: widget.appID, appSign: widget.appSign);
    await ZegoSignalPlugin().login(widget.userID, widget.userName);

    ZegoInvitationPageManager.instance.init(
      appID: widget.appID,
      appSign: widget.appSign,
      tokenServerUrl: widget.tokenServerUrl,
      userID: widget.userID,
      userName: widget.userName,
      configQuery: widget.requireConfig,
      contextQuery: () {
        return context;
      },
    );
  }

  void uninitContext() async {
    ZegoInvitationPageManager.instance.uninit();

    await ZegoSignalPlugin().logout();
    await ZegoSignalPlugin().unloadZim();
  }

  Future<void> reLoginContext(String userID, String userName) async {
    var localUser = ZegoSignalPlugin().getLocalUser();
    if (localUser.id == userID && localUser.name == userName) {
      debugPrint("same user, cancel this reLogin");
      return;
    }

    await ZegoSignalPlugin().logout();
    await ZegoSignalPlugin().login(userID, userName);
  }
}
