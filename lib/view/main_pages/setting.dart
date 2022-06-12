import 'package:chat_me/controller/authenticate_provider.dart';
import 'package:chat_me/controller/chat_provider.dart';
import 'package:chat_me/controller/localizations_provider.dart';
import 'package:chat_me/controller/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isDark = false;
  bool _isArabic = false;

  @override
  Widget build(BuildContext context) {
    _isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode();
    _isArabic = Provider.of<LocalizationsProvider>(context, listen: false).isArabic();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingPageTitle),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ExpansionTile(
              title: Text(
                AppLocalizations.of(context)!.themeOptionsTitle,
                style: Theme.of(context).textTheme.headline2,
              ),
              children: [
                CheckboxListTile(
                    title: Text(
                      AppLocalizations.of(context)!.themeOptionsDark,
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _isDark,
                    onChanged: (val) {
                      setState(() => _isDark = val ?? false);
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setDark(true);
                    }),
                CheckboxListTile(
                    title: Text(
                      AppLocalizations.of(context)!.themeOptionsLight,
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: !_isDark,
                    onChanged: (val) {
                      setState(() => _isDark = val == true
                          ? false
                          : (val == false)
                              ? true
                              : false);
                      Provider.of<ThemeProvider>(context, listen: false)
                          .setDark(false);
                    }),
              ],
            ),
            ExpansionTile(
              title: Text(
                AppLocalizations.of(context)!.languageOptionsTitle,
                style: Theme.of(context).textTheme.headline2,
              ),
              children: [
                CheckboxListTile(
                    title: Text(
                      AppLocalizations.of(context)!.languageOptionsArabic,
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _isArabic,
                    onChanged: (val) {
                      setState(() => _isArabic = val ?? false);
                      Provider.of<LocalizationsProvider>(context, listen: false)
                          .locale(const Locale('ar'));
                    }),
                CheckboxListTile(
                    title: Text(
                      AppLocalizations.of(context)!.languageOptionsEnglish,
                      style: TextStyle(
                        color: _isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: !_isArabic,
                    onChanged: (val) {
                      setState(() => _isArabic = val == true
                          ? false
                          : (val == false)
                              ? true
                              : false);
                      Provider.of<LocalizationsProvider>(context, listen: false)
                          .locale(const Locale('en'));
                    }),
              ],
            ),
            InkWell(
              onTap: () {
                context.read<AuthenticationProvider>().logOut();
                context.read<ChatProvider>().clearData();
              },
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.logOutOrder,
                  style: Theme.of(context).textTheme.headline2,
                ),
                trailing: const Icon(
                  Icons.logout,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
