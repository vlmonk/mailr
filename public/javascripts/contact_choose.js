
var fieldTo = ""
var fieldToc = ""
var fieldCC = ""
var fieldBCC = ""

function respondTo(str) {
  if (fieldTo == "") fieldTo += str
  else  fieldTo += "," + str
}

function respondTo(str, contactId) {
  if (fieldTo == "") fieldTo += str
  else  fieldTo += "," + str
  
  if (fieldToc == "") fieldToc += contactId
  else  fieldToc += "," + contactId
}

function respondCC(str) {
  if (fieldCC == "") fieldCC += str
  else  fieldCC += "," + str
}

function respondBCC(str) {
  if (fieldBCC == "") fieldBCC += str
  else  fieldBCC += "," + str
}

function respondToCaller() {
  if (window.opener) {
    doc = window.opener.document;
    setAddrField(getFormFieldPoint(doc, 'mail_to'), fieldTo);
    setAddrField(getFormFieldPoint(doc, 'mail_toc'), fieldToc);
    setAddrField(getFormFieldPoint(doc, 'mail_cc'), fieldCC);
    setAddrField(getFormFieldPoint(doc, 'mail_bcc'), fieldBCC);
    window.close();
  }
}

function getFormFieldPoint(doc, id) {
  if ( doc.getElementById ) elem = doc.getElementById( id );
  else if ( doc.all ) elem = doc.eval( "document.all." + id );
  return elem
}

function setAddrField(fld, value) {
  if (value != "") {
    if (fld.value == "") fld.value = value;
    else fld.value += "," + value;
  }
}