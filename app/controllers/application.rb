# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :localize
  before_filter :user_login_filter
  before_filter :add_scripts
  
  model :customer
  
  protected
    def secure_user?() true end
    def secure_cust?() false end
    def additional_scripts() "" end
    def onload_function() "" end
  
  private
    def add_scripts
      @additional_scripts = additional_scripts()
      @onload_function = onload_function()
    end
    
    def user_login_filter
      if (secure_user? or secure_cust? )and logged_user.nil?
        @session["return_to"] = @request.request_uri
        redirect_to :controller=>"/login", :action => "index"
        return false
      end
    end
  
    alias login_required user_login_filter   
      
    def logged_user # returns customer id
      @session['user']
    end

    def logged_customer
      @session['user']
    end
    
    def localize
      # We will use instance vars for the locale so we can make use of them in
      # the templates.
      @charset  = 'utf-8'
      @headers['Content-Type'] = "text/html; charset=#{@charset}"
      # Here is a very simplified approach to extract the prefered language
      # from the request. If all fails, just use 'en_EN' as the default.
      temp = if @request.env['HTTP_ACCEPT_LANGUAGE'].nil?
               []
             else
               @request.env['HTTP_ACCEPT_LANGUAGE'].split(',').first.split('-') rescue []
             end
      language = temp.slice(0)
      dialect  = temp.slice(1)
      @language = language.nil? ? 'en' : language.downcase # default is en
      # If there is no dialect use the language code ('en' becomes 'en_EN').
      @dialect  = dialect.nil? ? @language.upcase : dialect
      # The complete locale string consists of
      # language_DIALECT (en_EN, en_GB, de_DE, ...)
      @locale   = "#{@language}_#{@dialect.upcase}"
      @htmllang = @language == @dialect ? @language : "#{@language}-#{@dialect}"
      # Finally, bind the textdomain to the locale. From now on every used
      # _('String') will get translated into the right language. (Provided
      # that we have a corresponding mo file in the right place).
      bindtextdomain('messages', "#{RAILS_ROOT}/locale", @locale, @charset)
    end

  public
    
  def include_tinymce(mode="textareas",elements="")
    tinymce=''
    tinymce << '
       <script language="javascript" type="text/javascript" src="/tiny_mce/tiny_mce.js"></script>
       <script language="javascript" type="text/javascript">
       tinyMCE.init({
        mode : "'
    tinymce << mode << '",'
    if mode == "exact"
      tinymce << 'elements : "' << elements << '",
      ' 
    end
    tinymce << '
        theme : "advanced",
        cleanup : true,  
        width: "100%",
        remove_linebreaks : false,
        entity_encoding : "named",
        relative_urls : false,
        plugins : "table,save,advhr,advimage,advlink,iespell,preview,zoom,searchreplace,print,contextmenu,fullscreen,linkattach",
        theme_advanced_buttons1_add : "fontselect,fontsizeselect",
        theme_advanced_buttons2_add : "separator,preview,zoom",
        theme_advanced_buttons2_add_before: "cut,copy,paste,separator,search,replace,separator",
        theme_advanced_buttons3_add_before : "tablecontrols,separator",
        theme_advanced_buttons3_add : "iespell,forecolor,backcolor,fullscreen",
        theme_advanced_source_editor_width : "700",
        theme_advanced_source_editor_height : "500",
        theme_advanced_styles : "Header 1=header1",
        theme_advanced_toolbar_location : "top",
        theme_advanced_toolbar_align : "left",
        theme_advanced_path_location : "none",
        extended_valid_elements : ""
           +"a[accesskey|charset|class|coords|href|hreflang|id|lang|name"
              +"|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup"
              +"|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rel|rev"
              +"|shape|style|tabindex|title|target|type],"
           +"dd[class|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup"
              +"|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],"
           +"div[align|class|id|lang|onclick"
              +"|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove"
              +"|onmouseout|onmouseover|onmouseup|style|title],"
           +"dl[class|compact|id|lang|onclick|ondblclick|onkeydown"
              +"|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover"
              +"|onmouseup|style|title],"
           +"dt[class|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup"
              +"|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],"
           +"img[align|alt|border|class|height"
              +"|hspace|id|ismap|lang|longdesc|name|onclick|ondblclick|onkeydown"
              +"|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover"
              +"|onmouseup|src|style|title|usemap|vspace|width],"
           +"script[charset|defer|language|src|type],"
           +"style[lang|media|title|type],"
           +"table[align|bgcolor|border|cellpadding|cellspacing|class"
              +"|frame|height|id|lang|onclick|ondblclick|onkeydown|onkeypress"
              +"|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rules"
              +"|style|summary|title|width],"
           +"td[abbr|align|axis|bgcolor|char|charoff|class"
              +"|colspan|headers|height|id|lang|nowrap|onclick"
              +"|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove"
              +"|onmouseout|onmouseover|onmouseup|rowspan|scope"
              +"|style|title|valign|width],"
           +"hr[align|class|id|lang|noshade|onclick"
              +"|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove"
              +"|onmouseout|onmouseover|onmouseup|size|style|title|width],"
           +"font[class|color|face|id|lang|size|style|title],"
           +"span[align|class|class|id|lang|onclick|ondblclick|onkeydown"
              +"|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover"
              +"|onmouseup|style|title]",
        external_link_list_url : "/cms/urlchoose/choose_tinymce",
        external_attachments_list_url : "/attachments/attachments/choose_tinymce",
        external_image_list_url : "/gallery/imgchoose/choose_tinymce",
        flash_external_list_url : "example_data/example_flash_list.js"
      });
      </script>'
    tinymce
  end
  
  helper_method :include_tinymce

  def include_simple_tinymce(mode="textareas",elements="")
    tinymce = ''
    tinymce << '<script language="javascript" type="text/javascript" src="/tiny_mce/tiny_mce.js"></script>
       <script language="javascript" type="text/javascript"> 
      tinyMCE.init({
        mode : "'
    tinymce << mode << '",'
    if mode == "exact"
      tinymce << 'elements : "' << elements << '",
      ' 
    end
    tinymce << '
        theme : "default",
        width : "100%",
        auto_reset_designmode : true
      });      
      </script>'
    tinymce
  end
  
  helper_method :include_simple_tinymce

end
