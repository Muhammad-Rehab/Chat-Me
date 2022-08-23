import 'package:chat_me/controller/personalDataEntry_provider.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PersonalDataEntryScreen extends StatefulWidget {
  @override
  State<PersonalDataEntryScreen> createState() =>
      _PersonalDataEntryScreenState();
}

class _PersonalDataEntryScreenState extends State<PersonalDataEntryScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Form(
                key: Provider.of<PersonalDataEntryProvider>(context,
                        listen: false)
                    .formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Provider.of<PersonalDataEntryProvider>(context,
                                    listen: false)
                                .pickImage(ImageSource.camera);
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .personalEntryScreenCamera,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child:
                                (Provider.of<PersonalDataEntryProvider>(context)
                                            .image ==
                                        null)
                                    ? Image.asset(
                                        'assets/images/avatar.jpg',
                                        fit: BoxFit.fill,
                                      )
                                    : Image.file(
                                        Provider.of<PersonalDataEntryProvider>(
                                                context)
                                            .image!,
                                        fit: BoxFit.fill,
                                      ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<PersonalDataEntryProvider>(context,
                                    listen: false)
                                .pickImage(ImageSource.gallery);
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .personalEntryScreenGallery,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .personalEntryScreenFirstName,
                        labelStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onSaved: (value) {
                        Provider.of<PersonalDataEntryProvider>(context,
                                listen: false)
                            .personalDataMap['firstName'] = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .personalEntryScreenFirstNameError;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .personalEntryScreenLastName,
                        labelStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onSaved: (value) {
                        Provider.of<PersonalDataEntryProvider>(context,
                                listen: false)
                            .personalDataMap['lastName'] = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .personalEntryScreenLastNameError;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      maxLength: 100,
                      minLines: 1,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .personalEntryScreenStatus,
                        labelStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onSaved: (value) {
                        Provider.of<PersonalDataEntryProvider>(context,
                                listen: false)
                            .personalDataMap['status'] = value ?? '';
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Provider.of<PersonalDataEntryProvider>(context,
                                listen: false)
                            .isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () {
                              Provider.of<PersonalDataEntryProvider>(context,
                                      listen: false)
                                  .submitFunction(context);
                            },
                            child: Text(AppLocalizations.of(context)!
                                .personalEntryScreenCreateAccount),
                          ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
