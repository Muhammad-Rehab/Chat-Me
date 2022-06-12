

 List<Users> usersList = [];

class Users {

  String _id = '';
  String _activity = '';
  String _firstName = '';
  String _lastName = '';
  String _personalImage = '';
  String _phoneNumber = '';
  String _status = '';

  Users(String id,String activity,String firstName,String lastName,String personalImage,String phoneNumber,String status){
    _id = id ;
    _activity = activity;
    _firstName = firstName;
    _lastName = lastName ;
    _personalImage = personalImage ;
    _phoneNumber = phoneNumber ;
    _status = status ;
  }

  String get  id => _id ;
  String get activity => _activity ;
  String get firstName => _firstName ;
  String get lastName => _lastName ;
  String get personalImage => _personalImage ;
  String get phoneNumber => _phoneNumber ;
  String get status => _status ;


}