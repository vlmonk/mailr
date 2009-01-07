function chooseContacts() {
  rs('', '/contacts/contact/list?mode=choose',550,480,0);
}

function setBulk() {
  if (getFormField("mail_bulk").checked) getFormField("set_bulk").value = "set_bulk"
  document.forms['composeMail'].submit();
}

function getFormField(id) {
  if ( document.getElementById ) elem = document.getElementById( id );
  else if ( document.all ) elem = document.eval( "document.all." + id );
  return elem;
}

function toggle_msg_operations(setc) {
  var isOpened = toggle_layer('msgops');
  if (setc) setCookie("_wmlmo", ( isOpened ? "opened" : "closed"), 1000000);
}

function toggle_msg_search(setc) {
  var isOpened = toggle_layer('msg_search');
  if (setc) setCookie("_wmlms", (isOpened ? "opened" : "closed"), 1000000);
}

function checkAll(theForm) { // check all the checkboxes in the list
  for (var i=0;i<theForm.elements.length;i++) {
    var e = theForm.elements[i];
    var eName = e.name;
    if (eName != 'allbox' && 
        (e.type.indexOf("checkbox") == 0)) {
        e.checked = theForm.allbox.checked;		
    }
  } 
}