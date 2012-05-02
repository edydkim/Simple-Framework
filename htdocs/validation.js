function validate() {
  var f = document.forms[0];
  for (var i = 0; i < f.elements.length; i++) {
      var el = f.elements[i];
      if (el.type == "text" && el.value == "") {
         alert("Required..");
         el.focus();
         return false;
      }
  }
  return true;
}