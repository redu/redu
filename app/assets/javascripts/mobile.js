//= require bootstrap


$(function() {
  // Checkbox de mostrar senha.
  $(document).on("change", "#mobile-form-sign-in-show-password", function() {
    var $passwordField = $("#user_session_password");

    if ($(this).prop("checked")) {
      $passwordField.get(0).type = "text";
    } else {
      $passwordField.get(0).type = "password";
    }
  });
});