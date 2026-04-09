class AppValidator{

  //Empty text validation
  static String? validateEmptyText(String? fieldName, String? value){
    if (value == null || value.isEmpty){
      return "$fieldName is required";
    }
  }

  //validate username
  static String? validateUsername (String? value){
    if(value==null || value.isEmpty){
      return "Username is required";
    }

    return null;
  }

  //validate email address
  static String? validateEmail(String? value){
    if (value == null || value.isEmpty){
      return "Email is required";
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if(!emailRegExp.hasMatch(value)){
      return "Invalid email address";
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty){
      return "Password is required";
    }

    if(value.length < 6){
      return "Password must be at least 6 characters long";
    }

    return null;
  }
}