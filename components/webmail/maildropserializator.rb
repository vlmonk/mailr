module MaildropSerializator
  def serialize_to_file
    mail_drop_filter = File.new(self.mail_filter_path, "w")
    for filter in filters
      mail_drop_filter << "# filter '#{filter.name}'\n"
      mail_drop_filter << "if (#{filter_expressions(filter)})\n"
      mail_drop_filter << "{\n"
      mail_drop_filter << "  exception {\n" 
      mail_drop_filter << "    to #{dest_folder(filter)}\n" 
      mail_drop_filter << "  }\n" 
      mail_drop_filter << "}\n"
    end
    mail_drop_filter.close()
  end
  
  private
    def dest_folder(filter)
      '$DEFAULT/'<<filter.destination_folder.sub(Regexp.new("(#{CDF::CONFIG[:mail_inbox]})(.*)"), '\2')<<"/"
    end
    
    def escape_expr_value(text)
      text.gsub(".", "\\.").gsub("*", "\\*").gsub("[", "\\[").gsub("]", "\\]").gsub("(", "\\(").gsub(")", "\\)").
        gsub("?", "\\?")
    end
    
    def filter_expressions(filter)
      fe = ""
      for exp in filter.expressions 
        post_flag = "h"
        fe << " && " unless fe == ""
        if exp.field_name == "^Body"
          fe << "/"
          post_flag = "b"
        else
          fe << "/#{exp.field_name}:"
        end
        if exp.operator == 'contains'
          fe << ".*(#{escape_expr_value(exp.expr_value)})/"
        else
          # starts with
          fe << "[ ]*(#{escape_expr_value(exp.expr_value)}).*/"
        end
        if exp.case_sensitive == 1
          fe << "D" << post_flag
        else
          fe << post_flag  
        end  
      end  
      fe
    end
  end
