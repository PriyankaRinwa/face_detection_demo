class Validation {
  static String? emailValidation(String? email){
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if(email!.isEmpty){
      return "email should not be empty";
    } else if(!regex.hasMatch(email)){
       return "email not valid";
     }
    return null;
  }

  static String? nameValidation(String? name){
    final regex = RegExp(r'^[A-Za-z0-9-_ ]{2,30}$');
    if((name== null && name!.isEmpty) || name.trim().isEmpty){
      return "name should not be empty or blank.";
    }else if(!regex.hasMatch(name)){
      return "3-30 characters, alphanumeric, underscores, and hyphens";
    } return null;
  }

  static String? employeeIdValidation(String? value){
    if((value==null && value!.isEmpty) || value.trim().isEmpty){
      return "name should not be empty or blank";
    }return null;
  }

}