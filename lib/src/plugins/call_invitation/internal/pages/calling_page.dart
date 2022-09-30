// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Project imports:
import 'package:zego_uikit_signal_plugin/src/plugins/call_invitation/internal/page_manager.dart';
import 'package:zego_uikit_signal_plugin/src/plugins/call_invitation/prebuilt_call_invitation_defines.dart';
import 'package:zego_uikit_signal_plugin/src/services/services.dart';
import 'calling_machine.dart';
import 'calling_view.dart';

class ZegoCallingPage extends StatefulWidget {
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;

  final VoidCallback onInitState;
  final VoidCallback onDispose;

  const ZegoCallingPage({
    Key? key,
    required this.inviter,
    required this.invitees,
    required this.onInitState,
    required this.onDispose,
  }) : super(key: key);

  @override
  ZegoCallingPageState createState() => ZegoCallingPageState();
}

class ZegoCallingPageState extends State<ZegoCallingPage> {
  CallingState currentState = CallingState.kIdle;

  VoidCallback? callConfigHandUp;
  VoidCallback? callConfigOnlySelfInRoom;
  ZegoUIKitPrebuiltCallConfig? callConfig;

  final ZegoCallingMachine machine =
      ZegoInvitationPageManager.instance.callingMachine;

  ZegoInvitationPageManager get pageService =>
      ZegoInvitationPageManager.instance;

  @override
  void initState() {
    super.initState();

    widget.onInitState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.onStateChanged = (CallingState state) {
        setState(() {
          currentState = state;
        });
      };

      if (null != machine.machine.current) {
        machine.onStateChanged!(machine.machine.current!.identifier);
      }
    });
  }

  @override
  void dispose() {
    widget.onDispose();

    machine.onStateChanged = null;

    callConfig = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localUserInfo = ZegoSignalPlugin().getLocalUser();

    late Widget view;
    switch (currentState) {
      case CallingState.kIdle:
        view = const SizedBox();
        break;
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        callConfig = null;

        var localUserIsInviter = localUserInfo.id == widget.inviter.id;
        var callingView = localUserIsInviter
            ? ZegoCallingInviterView(
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: pageService.invitationData.type,
                avatarBuilder: pageService
                    .configQuery(pageService.invitationData)
                    .avatarBuilder,
              )
            : ZegoCallingInviteeView(
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: pageService.invitationData.type,
                avatarBuilder: pageService
                    .configQuery(pageService.invitationData)
                    .avatarBuilder,
              );
        view = ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return callingView;
          },
        );
        break;
      case CallingState.kOnlineAudioVideo:
        view = prebuiltCallPage();
        break;
    }

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(
          child: view,
        ));
  }

  void onCallHandUp() {
    callConfigHandUp?.call();
    pageService.onHangUp();
  }

  void onOnlySelfInRoom() {
    callConfigOnlySelfInRoom?.call();
    pageService.onOnlySelfInRoom();
  }

  Widget prebuiltCallPage() {
    callConfig = pageService.configQuery(pageService.invitationData);

    callConfigHandUp = callConfig?.onHangUp;
    callConfig?.onHangUp = onCallHandUp;
    callConfig?.onOnlySelfInRoom = onOnlySelfInRoom;

    switch (pageService.invitationData.type) {
      case ZegoInvitationType.voiceCall:
        callConfig?.bottomMenuBarConfig.buttons = const [
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.hangUpButton,
          ZegoMenuBarButtonName.switchAudioOutputButton,
        ];
        break;
      case ZegoInvitationType.videoCall:
        callConfig?.bottomMenuBarConfig.buttons = const [
          ZegoMenuBarButtonName.toggleCameraButton,
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.hangUpButton,
          ZegoMenuBarButtonName.switchAudioOutputButton,
          ZegoMenuBarButtonName.switchCameraButton,
        ];
        break;
    }

    return ZegoUIKitPrebuiltCall(
      appID: pageService.appID,
      appSign: pageService.appSign,
      callID: pageService.invitationData.callID,
      userID: pageService.userID,
      userName: pageService.userName,
      tokenServerUrl: pageService.tokenServerUrl,
      config: callConfig!,
    );
  }
}
