
import 'package:chat_me/controller/authenticate_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthenticateScreen extends StatefulWidget {
  const AuthenticateScreen({Key? key}) : super(key: key);

  @override
  _AuthenticateScreenState createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  bool _isVerifyScreen = false;

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpVerificationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return (_isVerifyScreen)
        ? Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).primaryColor,
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _otpVerificationController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.logInScreenOTP,
                          labelStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (_otpVerificationController.text.length > 6) {
                            Scaffold.of(context).showBottomSheet((context) =>
                                 Text(AppLocalizations.of(context)!.logInScreenOTPError));
                          } else {
                            context
                                .read<AuthenticationProvider>()
                                .verifyPhoneAuth(
                                    _otpVerificationController.text, context);
                          }
                        },
                        child:  Text(AppLocalizations.of(context)!.logInScreenVerify),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Theme.of(context).primaryColor,
              ),
              Center(
                child: Form(
                  key: _formKey,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null) {
                              return AppLocalizations.of(context)!.logInScreenPhoneError1;
                            } else if (value.length > 11) {
                              return AppLocalizations.of(context)!.logInScreenPhoneError2;
                            } else if (int.tryParse(value) == null) {
                              return AppLocalizations.of(context)!.logInScreenPhoneError3;
                            }
                          },
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.logInScreenPhoneNumber,
                            prefixText: '+2',
                            prefixStyle: const TextStyle(color: Colors.black),
                            labelStyle: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _formKey.currentState!.validate();
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<AuthenticationProvider>()
                                  .logIn(_phoneNumberController.text, context);
                              setState(() {
                                _isVerifyScreen = !_isVerifyScreen;
                              });
                            }
                            },
                          child:  Text(AppLocalizations.of(context)!.logInScreenSendSMS),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
