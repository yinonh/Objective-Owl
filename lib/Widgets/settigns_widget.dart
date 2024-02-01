import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do/Providers/notification_provider.dart';
import 'package:to_do/Screens/statistics_screen.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

import '../Utils/shared_preferences_helper.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../Widgets/notification_time.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<bool> _selectedLanguages = [true, false];
  late NotificationProvider notificationProvider;
  late NotificationTime _time;
  late bool _notificationsActive;
  List<Widget> languages = <Widget>[
    Image.asset(
      'Assets/english.png',
      width: 60,
      height: 45,
    ),
    Image.asset(
      'Assets/hebrew.png',
      width: 60,
      height: 45,
    )
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSharedPreferences();
    notificationProvider = Provider.of<NotificationProvider>(context);
    _time = notificationProvider.notificationTime;
    _notificationsActive = notificationProvider.isActive;
  }

  Future<void> _loadSharedPreferences() async {
    String selectedLanguage =
        SharedPreferencesHelper.instance.selectedLanguage ??
            Localizations.localeOf(context).languageCode;

    setState(() {
      _selectedLanguages =
          selectedLanguage == 'he' ? [false, true] : [true, false];
    });
  }

  void onTimeChanged(Time originalTime) {
    NotificationTime newTime = NotificationTime(
        hour: originalTime.hour, minute: originalTime.minute, second: 0);
    Provider.of<NotificationProvider>(context, listen: false)
        .saveNotificationTimeToPrefs(newTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context).translate("Choose language:"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: ToggleButtons(
                  onPressed: (int index) async {
                    setState(() {
                      _selectedLanguages = List.generate(
                          _selectedLanguages.length, (i) => i == index);
                    });

                    String newLanguageCode = index == 0 ? 'en' : 'he';
                    SharedPreferencesHelper.instance.selectedLanguage =
                        newLanguageCode;

                    Locale newLocale = Locale(newLanguageCode);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      OwlistApp.setLocale(context, newLocale);
                    });
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedColor: Theme.of(context).primaryColor,
                  fillColor: Theme.of(context).primaryColorLight,
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                  isSelected: _selectedLanguages,
                  children: languages,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    OwlistApp.isDark(context)
                        ? AppLocalizations.of(context)
                            .translate("Switch to light mode")
                        : AppLocalizations.of(context)
                            .translate("Switch to dark mode"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Transform.scale(
                  scale: 1,
                  child: Switch(
                    activeThumbImage: const AssetImage('Assets/darkMode.png'),
                    inactiveThumbImage:
                        const AssetImage('Assets/lightMode.png'),
                    onChanged: (mode) async {
                      SharedPreferencesHelper.instance.selectedTheme =
                          mode ? "dark" : "light";
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        OwlistApp.setTheme(context, mode);
                      });
                    },
                    value: OwlistApp.isDark(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("Enable notifications:"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Transform.scale(
                  scale: 1,
                  child: Switch(
                    onChanged: (val) {
                      notificationProvider.saveActive(val);
                    },
                    value: _notificationsActive,
                    trackColor: MaterialStateProperty.all<Color>(
                        _notificationsActive
                            ? Theme.of(context).primaryColorLight
                            : Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("Choose default time for notification:"),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: Transform.scale(
                  scale: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ElevatedButton(
                      onPressed: _notificationsActive
                          ? () {
                              Navigator.of(context).push(
                                showPicker(
                                  height: 350,
                                  is24HrFormat: true,
                                  accentColor: Theme.of(context).highlightColor,
                                  context: context,
                                  showSecondSelector: false,
                                  value: _time,
                                  onChange: onTimeChanged,
                                  minuteInterval: TimePickerInterval.FIVE,
                                  okText: AppLocalizations.of(context)
                                      .translate("Ok"),
                                  cancelText: AppLocalizations.of(context)
                                      .translate("Cancel"),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        AppLocalizations.of(context).translate("Choose time"),
                        style: _notificationsActive
                            ? Theme.of(context)
                                .primaryTextTheme
                                .titleMedium!
                                .copyWith(color: Colors.white)
                            : Theme.of(context)
                                .primaryTextTheme
                                .titleMedium!
                                .copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(StatisticsScreen.routeName);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  AppLocalizations.of(context).translate("Statistics"),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Text(
            AppLocalizations.of(context)
                .translate("All the changes will take effect from now on only"),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
