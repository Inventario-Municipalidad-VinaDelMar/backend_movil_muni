import 'package:animate_do/animate_do.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';
import 'package:frontend_movil_muni/config/sidemenu/sidemenu_items.dart';
import 'package:frontend_movil_muni/src/providers/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key, required this.side});

  final ShadSheetSide side;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    return SafeArea(
      child: ShadSheet(
        backgroundColor: Colors.blue[500],
        padding: EdgeInsets.only(top: size.height * 0.03),
        removeBorderRadiusWhenTiny: false,
        radius: const BorderRadius.only(
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
        scrollable: false,
        border: Border.all(
          color: Colors.transparent,
        ),
        constraints: side == ShadSheetSide.left || side == ShadSheetSide.right
            ? BoxConstraints(maxWidth: size.width * 0.7)
            : null,
        descriptionStyle: textStyles.h4,
        title: const _HeaderMenu(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...sidemenuItems.map((item) {
                return Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    splashColor: colors.muted.withOpacity(.2),
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (item.link != null && context.mounted) {
                        context.push(item.link!);
                        return;
                      }

                      if (userProvider.user != null) {
                        await authProvider.signOutUser().then((value) {
                          context.pop();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      height: size.height * 0.09,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[900]!.withOpacity(.35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AnimateIcon(
                              onTap: () {},
                              iconType: IconType.continueAnimation,
                              height: 20,
                              width: 20,
                              color: Colors.white,
                              animateIcon: item.icon,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: textStyles.large.copyWith(
                                  color: Colors.white.withOpacity(.85),
                                ),
                              ),
                              Text(
                                item.subTitle,
                                style: textStyles.small.copyWith(
                                  color: Colors.white.withOpacity(.6),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderMenu extends StatelessWidget {
  const _HeaderMenu();

  @override
  Widget build(BuildContext context) {
    final textStyles = ShadTheme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;
    final userProvider = context.watch<UserProvider>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeIn(
          child: ShadAvatar(
            size: Size(
              size.height * 0.07,
              size.height * 0.07,
            ),
            userProvider.user?.imageUrl ??
                'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/124599?v=4',
            placeholder: SkeletonAvatar(
              style: SkeletonAvatarStyle(
                shape: BoxShape.circle,
                width: size.height * 0.05,
                height: size.height * 0.05,
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width * 0.5,
              alignment: Alignment.centerLeft,
              child: Wrap(
                children: [
                  Text(
                    '${userProvider.user?.nombre} ${userProvider.user?.apellidoPaterno} ${userProvider.user?.apellidoMaterno}',
                    style: textStyles.large.copyWith(color: Colors.white),
                    softWrap: true,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            Container(
              width: size.width * 0.5,
              alignment: Alignment.centerLeft,
              child: Wrap(
                children: [
                  Text(
                    userProvider.user?.email ?? 'No email',
                    style: textStyles.p.copyWith(
                      color: Colors.white.withOpacity(.5),
                    ),
                    softWrap: true,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
