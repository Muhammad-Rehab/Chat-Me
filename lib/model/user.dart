List<Users> usersList = [];

class Users {
  String _id = '';
  String _activity = '';
  String _firstName = '';
  String _lastName = '';
  String _personalImage = '';
  String _phoneNumber = '';
  String _status = '';
  String _appToken = '';

  Users(String id, String activity, String firstName, String lastName,
      String personalImage, String phoneNumber, String status,
      {String appToken = ''}) {
    _id = id;
    _activity = activity;
    _firstName = firstName;
    _lastName = lastName;
    _personalImage = personalImage;
    _phoneNumber = phoneNumber;
    _status = status;
    _appToken = appToken;
  }

  String get id => _id;

  String get activity => _activity;

  String get firstName => _firstName;

  String get lastName => _lastName;

  String get personalImage => _personalImage;

  String get phoneNumber => _phoneNumber;

  String get status => _status;

  String get appToken => _appToken;
}
