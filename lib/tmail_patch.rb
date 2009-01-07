module TMail
	class Mail
	  def parse_header( f )
      name = field = nil
      unixfrom = nil
    
      while line = f.gets
        case line
        when /\A[ \t]/             # continue from prev line
          raise SyntaxError, 'mail is began by space' unless field
          field << ' ' << line.strip

        when /\A([^\: \t]+):\s*/   # new header line
          add_hf name, field if field
          name = $1
          field = $' #.strip
        
        when /\A\-*\s*\z/          # end of header
          add_hf name, field if field
          name = field = nil
          break

        when /\AFrom (\S+)/
          unixfrom = $1
        else
          # treat as continue from previos
          raise SyntaxError, 'mail is began by space' unless field
          field << ' ' << line.strip
        end
      end
      add_hf name, field if name

      if unixfrom
        add_hf 'Return-Path', "<#{unixfrom}>" unless @header['return-path']
      end
    end		
	end
end
