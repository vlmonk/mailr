/* Import plugin specific language pack */
tinyMCE.importPluginLanguagePack('linkattach', 'en,de,sv,zh_cn,cs,fa,fr_ca,fr,pl');

/**
 * Insert link template function.
 */
function TinyMCE_linkattach_getInsertAttachmentTemplate() {
    var template = new Array();
    template['file']   = '../../plugins/linkattach/attachment.htm';
    template['width']  = 400;
    template['height'] = 420;

    // Language specific width and height addons
    template['width']  += tinyMCE.getLang('lang_insert_attachment_delta_width', 0);
    template['height'] += tinyMCE.getLang('lang_insert_attachment_delta_height', 0);

    return template;
} 