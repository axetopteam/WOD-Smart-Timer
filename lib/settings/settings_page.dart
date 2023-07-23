import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:smart_timer/core/context_extension.dart';
import 'package:smart_timer/core/localization/locale_keys.g.dart';
import 'package:smart_timer/purchasing/paywalls/paywall_page.dart';
import 'package:smart_timer/purchasing/premium_state.dart';
import 'package:smart_timer/services/app_review_service.dart';
import 'package:smart_timer/utils/utils.dart';

import 'settings_state.dart';
import 'support.dart/application_support.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _state = SettingsState();
  late final PremiumState premiumState;

  @override
  void initState() {
    premiumState = context.read<PremiumState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings_title.tr()),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _generalBlock(),
          _planBlock(),
          _soundBlock(),
          _legalBlock(),
        ],
      ),
    );
  }

  Widget _generalBlock() {
    return CupertinoListSection.insetGrouped(
      backgroundColor: context.color.background,
      header: Text(
        LocaleKeys.settings_general.tr().toUpperCase(),
        style: context.textTheme.titleMedium?.copyWith(color: context.color.secondaryText),
      ),
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      decoration: BoxDecoration(
        color: context.color.containerBackground,
      ),
      children: [
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_rate_us.tr()),
          leading: const Icon(CupertinoIcons.star_fill),
          onTap: () {
            AppReviewService().openStoreListing();
          },
        ),
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_contact_us.tr()),
          leading: const Icon(CupertinoIcons.at),
          onTap: () => ApplicationSupport.showSupportDialog(context),
        ),
      ],
    );
  }

  Widget _planBlock() {
    return CupertinoListSection.insetGrouped(
      backgroundColor: context.color.background,
      header: Text(
        LocaleKeys.settings_plan_title.tr().toUpperCase(),
        style: context.textTheme.titleMedium?.copyWith(color: context.color.secondaryText),
      ),
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      decoration: BoxDecoration(
        color: context.color.containerBackground,
      ),
      children: [
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_plan_purchase.tr()),
          leading: const Icon(CupertinoIcons.star_circle_fill),
          onTap: () {
            PaywallPage.show(context);
          },
        ),
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_plan_title.tr()),
          leading: const Icon(CupertinoIcons.checkmark_seal),
          trailing: Observer(builder: (ctx) {
            return Container(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 4),
              decoration: BoxDecoration(
                color: premiumState.isPremiumActive ? context.color.premium : context.color.warning,
                borderRadius: BorderRadius.circular(6),
              ),
              child: premiumState.isPremiumActive
                  ? Text(LocaleKeys.settings_plan_active.tr())
                  : Text(LocaleKeys.settings_plan_inactive.tr()),
            );
          }),
        ),
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_plan_restore.tr()),
          leading: const Icon(Icons.cloud_download),
          onTap: () {}, //TODO: add restore
        ),
      ],
    );
  }

  Widget _soundBlock() {
    return CupertinoListSection.insetGrouped(
      header: Text(
        LocaleKeys.settings_sound.tr().toUpperCase(),
        style: context.textTheme.titleMedium?.copyWith(color: context.color.secondaryText),
      ),
      backgroundColor: context.color.background,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.color.containerBackground,
      ),
      children: [
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_sound_on.tr()),
          leading: const Icon(CupertinoIcons.speaker_3_fill),
          trailing: Observer(
            builder: (context) {
              final soundOn = _state.soundOn;
              if (soundOn != null) {
                return CupertinoSwitch(
                  value: soundOn,
                  applyTheme: true,
                  onChanged: (value) {
                    _state.saveSoundOn(value);
                  },
                );
              } else {
                return const CupertinoActivityIndicator();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _legalBlock() {
    return CupertinoListSection.insetGrouped(
      header: Text(
        LocaleKeys.settings_legal.tr().toUpperCase(),
        style: context.textTheme.titleMedium?.copyWith(color: context.color.secondaryText),
      ),
      backgroundColor: context.color.background,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.color.containerBackground,
      ),
      children: [
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_privacy_policy.tr()),
          leading: const Icon(CupertinoIcons.checkmark_shield_fill),
          onTap: AppUtils.openPrivacyPolicy,
        ),
        CupertinoListTile.notched(
          title: Text(LocaleKeys.settings_terms_of_use.tr()),
          leading: const Icon(CupertinoIcons.doc_plaintext),
          onTap: AppUtils.openTermsOfUse,
        ),
      ],
    );
  }
}
