function changeLoc(loc) { window.location = loc }
function getCookie(name) {
  var prefix = name + "="; 
  var cStr = document.cookie;
  var start = cStr.indexOf(prefix);
  if (start==-1) {
    return null;
  }
  
  var end = cStr.indexOf(";", start+prefix.length);
  if (end==-1) { end=cStr.length; }

  var value=cStr.substring(start+prefix.length, end);
  return unescape(value);
}
function setCookie(name, value, expiration) { 
  document.cookie = name+"="+value+"; expires="+expiration;
}
function toggleCheckbox(checkBox) {
  var element = document.getElementById(checkBox.id);
  if (element.value == "1" || element.checked) {
      element.checked = false;
      element.value = "0";
  } else {
      element.checked = true;
      element.value = "1";
  }
}
function toggleChkbox(checkBox) {
  if (checkBox.checked) {
      checkBox.checked = true;
  } else {
      checkBox.checked = false;
  }
}
function toggle_list(id){
    ul = "ul_" + id;
    img = "img_" + id;
    hid = "h_" + id;
    ulElement = document.getElementById(ul);
    imgElement = document.getElementById(img);
    hiddenElement = document.getElementById(hid);
    if (ulElement){
      if (ulElement.className == 'closed'){
          ulElement.className = "open";
            imgElement.src = "/images/list_opened.gif";
            hiddenElement.value = "1"
        }else{
          ulElement.className = "closed";
            imgElement.src = "/images/list_closed.gif";
            hiddenElement.value = "0"
        }
    }
}
function toggle_layer(id) {
  lElement = document.getElementById(id);
  imgElement = document.getElementById("img_" + id);
  if (lElement){
    if (lElement.className == 'closed'){
        lElement.className = "open";
        imgElement.src = "/images/list_opened.gif";
        return true;
      }else{
        lElement.className = "closed";
        imgElement.src = "/images/list_closed.gif";
        return false;
      }
  }
  return true;
}
function toggle_layer_status(id) {
  lElement = document.getElementById(id);
  if (lElement){
    if (lElement.className == 'closed'){
        return false;
      }else{
        return true;
      }
  }
  return true;
}
function toggle_text(id){
  if ( document.getElementById )
      elem = document.getElementById( id );
    else if ( document.all )
      elem = eval( "document.all." + id );
    else
      return false;
    
    if(!elem) return true;
    
    elemStyle = elem.style;
    if ( elemStyle.display != "block" ) {
      elemStyle.display = "block"
    } else {
      elemStyle.display = "none"
    }
    return true;
}
function getFF(id) {
  if ( document.getElementById ) elem = document.getElementById( id );
  else if ( document.all ) elem = document.eval( "document.all." + id );
  return elem
}
function setFF(id, value) {if(getFF(id))getFF(id).value=value;}
function setCFF(id) {if(getFF(id))getFF(id).checked=true;}
function updateSUFromC(btnName) {
  var suem = getCookie('_cdf_em');var sueg = getCookie('_cdf_gr');
  if (suem != "" && suem != null && suem != "undefined") { setFF('sup_email', suem); setFF('signup_submit_button',btnName); }
  
  if (sueg && sueg != "") {
    if (sueg.indexOf(",") < 0 && sueg != "") { gr_id = sueg; setCFF('supgr_'+gr_id);
    } else while ((i = sueg.indexOf(",")) >= 0) { gr_id = sueg.substring(0,i); sueg = sueg.substring(i+1); setCFF('supgr_'+gr_id); }
    if (sueg.indexOf(",") < 0 && sueg != "") { gr_id = sueg; setCFF('supgr_'+gr_id);}
  }
}
function updateLUEfC() {
  var suem = getCookie('_cdf_em');
  if (suem != "" && suem != null && suem != "undefined") { setFF('login_user_email', suem); }
}
function replaceHRFST(ifrm) {
  var o = ifrm;
  var w = null;
  if (o.contentWindow) {
    // For IE5.5 and IE6
    w = o.contentWindow;
  } else if (window.frames && window.frames[o.id].window) {
    w = window.frames[o.id];
  } else return;
  var doc = w.document;
  if (!doc.getElementsByTagName) return;
  var anchors = doc.getElementsByTagName("a");
  for (var i=0; i<anchors.length; i++) {
     var anchor = anchors[i];
     if (anchor.getAttribute("href")) anchor.target = "_top";
  } 
  iHeight = doc.body.scrollHeight;
  ifrm.style.height = iHeight + "px"
}
function rs(n,u,w,h,x){
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes,status=0";
  remote=window.open(u,n,args);
  if(remote != null && remote.opener == null) remote.opener = self;
  if(x == 1) return remote;
}
function wizard_step_onclick(direction, alt_url) {
    if(document.forms[0]) {
        direction_elem='';
  
        if ( document.getElementById ) {
      direction_elem = document.getElementById( 'wiz_dir' );
        } else if ( document.all ) {
            direction_elem = document.eval( "document.all.wiz_dir");
        }      
        if(direction_elem) {
            direction_elem.value = direction;
        }
        if (document.forms[0].onsubmit) {
            document.forms[0].onsubmit();
        }   
        document.forms[0].submit();
    } else {
        window.location=alt_url;
    }
}
function toggle_adtype(ad_type){  
  toggle_text('upload_banner_label');
  toggle_text('upload_banner');
  toggle_text('radio1_label');
  toggle_text('radio1');
  toggle_text('radio2_label');
  toggle_text('radio2');
  toggle_text('adtitle_label');
  toggle_text('adtitle');
  toggle_text('adtext_label');
  toggle_text('adtext');
  toggle_text('banner_size_label');
  toggle_text('banner_size');
  
}
function show_date_as_local_time() {
  var spans = document.getElementsByTagName('span');
  for (var i=0; i<spans.length; i++)
    if (spans[i].className.match(/\bLOCAL_TIME\b/i)) {
      system_date = new Date(Date.parse(spans[i].innerHTML));
      if (system_date.getHours() >= 12) { adds = '&nbsp;PM'; h = system_date.getHours() - 12; } 
      else { adds = '&nbsp;AM'; h = system_date.getHours(); }
      spans[i].innerHTML = h + ":" + (system_date.getMinutes()+"").replace(/\b(\d)\b/g, '0$1') + adds;    
    }
}
function PopupPic(sPicURL,sWidth,sHeight) {
    window.open( "/popup.htm?"+sPicURL, "", "resizable=1,HEIGHT="+sHeight+",WIDTH="+sWidth+",scrollbars=yes");
}

function open_link(target, location){
  if (target == 'blank'){
   window.open(location);
  } else {
   window.top.location = location;
  }
}