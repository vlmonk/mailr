var config = new HTMLArea.Config(); // create a new configuration object
                                    // having all the default values
config.width = '520px';
config.pageStyle =
  'body { font-family: verdana,sans-serif; font-size: 12px } ';

config.toolbar = [
[ "fontname", "fontsize","formatblock","bold", "italic", "underline", "separator", "insertimage", "createlink"],
["justifyleft", "justifycenter", "justifyright", "justifyfull", "separator", "forecolor", "hilitecolor", "separator", "popupeditor", "htmlmode"]
];
config.statusBar = false;

var configView = new HTMLArea.Config(); // create a new configuration object
                                    // having all the default values
configView.width = '670px';
configView.pageStyle =
  'body { font-family: verdana,sans-serif; font-size: 12px } ';

configView.toolbar = [];
configView.statusBar = false;
configView.readonly = true;