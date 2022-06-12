
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationsProvider extends ChangeNotifier {

  static Locale currentLocale =  const Locale('en');

  static initLocal () async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance() ;
    bool  isArabic = sharedPreferences.getBool('isArabic')??false;
    if(isArabic){
      currentLocale = const Locale('ar');
    }
    return currentLocale ;
  }


  bool isArabic(){
    if(currentLocale.languageCode == 'ar'){
      return true ;
    }else{
      return false ;
    }
  }

   locale (Locale locale) async {
    if(!AppLocalizations.supportedLocales.contains(locale))
      {
        return ;
      }
    currentLocale = locale ;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance() ;
    sharedPreferences.setBool('isArabic',isArabic() );
    notifyListeners();
  }

}