// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// Project imports:
import 'package:zego_uikit_signal_plugin/src/components/components.dart';
import 'package:zego_uikit_signal_plugin/src/components/internal/internal.dart';
import 'package:zego_uikit_signal_plugin/src/plugins/call_invitation/internal/page_manager.dart';
import 'package:zego_uikit_signal_plugin/src/plugins/call_invitation/prebuilt_call_invitation_defines.dart';

class ZegoInviterCallingBottomToolBar extends StatelessWidget {
  final List<ZegoUIKitUser> invitees;

  const ZegoInviterCallingBottomToolBar({
    Key? key,
    required this.invitees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Center(
        child: ZegoCancelInvitationButton(
          invitees: invitees.map((e) => e.id).toList(),
          icon: ButtonIcon(
            icon: Image(
              image: SignalPluginImage.asset(
                      InvitationStyleIconUrls.toolbarBottomCancel)
                  .image,
              fit: BoxFit.fill,
            ),
          ),
          buttonSize: Size(120.r, 120.r),
          iconSize: Size(120.r, 120.r),
          onPressed: () {
            ZegoInvitationPageManager.instance.onLocalCancelInvitation();
          },
        ),
      ),
    );
  }
}

class ZegoInviteeCallingBottomToolBar extends StatefulWidget {
  final ZegoInvitationType invitationType;
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;

  const ZegoInviteeCallingBottomToolBar({
    Key? key,
    required this.inviter,
    required this.invitees,
    required this.invitationType,
  }) : super(key: key);

  @override
  State<ZegoInviteeCallingBottomToolBar> createState() {
    return ZegoInviteeCallingBottomToolBarState();
  }
}

class ZegoInviteeCallingBottomToolBarState
    extends State<ZegoInviteeCallingBottomToolBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZegoRefuseInvitationButton(
              inviterID: widget.inviter.id,
              text: "Decline",
              icon: ButtonIcon(
                icon: Image(
                  image: SignalPluginImage.asset(
                          InvitationStyleIconUrls.toolbarBottomDecline)
                      .image,
                  fit: BoxFit.fill,
                ),
              ),
              buttonSize: Size(120.r, 120.r + 50.r),
              iconSize: Size(120.r, 120.r),
              onPressed: () {
                ZegoInvitationPageManager.instance.onLocalRefuseInvitation();
              },
            ),
            SizedBox(width: 230.r),
            ZegoAcceptInvitationButton(
              inviterID: widget.inviter.id,
              icon: ButtonIcon(
                icon: Image(
                  image: SignalPluginImage.asset(
                          imageURLByInvitationType(widget.invitationType))
                      .image,
                  fit: BoxFit.fill,
                ),
              ),
              text: "Accept",
              buttonSize: Size(120.r, 120.r + 50.r),
              iconSize: Size(120.r, 120.r),
              onPressed: () {
                ZegoInvitationPageManager.instance.onLocalAcceptInvitation();
              },
            ),
          ],
        ),
      ),
    );
  }

  String imageURLByInvitationType(ZegoInvitationType invitationType) {
    switch (invitationType) {
      case ZegoInvitationType.voiceCall:
        return InvitationStyleIconUrls.toolbarBottomVoice;
      case ZegoInvitationType.videoCall:
        return InvitationStyleIconUrls.toolbarBottomVideo;
    }
  }
}
