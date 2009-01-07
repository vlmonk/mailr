#!/usr/bin/env ruby
=begin
  rgettext - ruby version of xgettext
  Copyright (C) 2005       Sascha Ebach
  Copyright (C) 2003,2004  Masao Mutoh
  Copyright (C) 2001,2002  Yasushi Shoji, Masao Mutoh
 
      Yasushi Shoji   <yashi@yashi.com>
      Masao Mutoh     <mutoh@highway.ne.jp>
      Sascha Ebach    <se@digitale-wertschoepfung.de>

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  2005-03-12: Added support for eruby templates (Sascha Ebach)
  2005-03-20: Added second parameter to RGetext.start to allow different
              output when not called from the command line. Pulled out
              RGetext.set_output().

=end

require 'gettext/parser/ruby'
require 'gettext/parser/glade'

require 'getoptlong'
require 'gettext'

require 'tempfile'
require 'erb'

class RGettext
  include GetText

  # constant values
  VERSION = %w($Revision: 1.15 $)[1].scan(/\d+/).collect {|s| s.to_i}
  DATE = %w($Date: 2004/11/05 18:19:08 $)[1]
  MAX_LINE_LEN = 70

  def start(files=ARGV, output = nil)
    opt = check_options
    opt['output'] = output unless output.nil?
    set_output(opt)
    
    
    if files.empty?
      print_help
      exit
    end

    ary = []
    files.each do |file|
      begin
        $stderr.puts "Processing #{file}"
        if glade_file?(file)
          ary = GladeParser.parse(file, ary)
        elsif erb_file?(file)
          content = File.open(file, 'r') {|f| f.read }
          tf = Tempfile.new('erb-gettext')
          tf.puts ERB.new(content).src
          tf.close
          old_index = ary.size - 1
          ary = GetText::RubyParser.parse(tf.path, ary)
                    #replace tokens with /tmp/... with real file names
          for i in old_index..ary.size-1
            for j in 0..ary[i].size-1
              ary[i][j] = ary[i][j].gsub("#{tf.path}", file)
            end
          end
          tf.close true
        else
          ary = RubyParser.parse(file, ary)
        end
      rescue
        puts $!
        exit 1
      end
    end
    generate_pot_header
    generate_pot(ary)
		@out.close
  end

  # following methods are
  private
  XML_RE = /<\?xml/ 
  GLADE_RE = /glade-2.0.dtd/

  def erb_file?(file)
    File.extname(file) == '.rhtml'
  end
  
  def glade_file?(file)
    data = IO.readlines(file)
    if XML_RE =~ data[0]
      if GLADE_RE =~ data[1]
        return true
      else
        raise _("%s is not glade-2.0 format.") % [file]
      end
    else
      return false
    end
  end

  def initialize
    bindtextdomain("rgettext")
  end

  def generate_pot_header
    time = Time.now.strftime("%Y-%m-%d %H:%M%z")
    @out << "# SOME DESCRIPTIVE TITLE.\n"
    @out << "# Copyright (C) YEAR THE PACKAGE'S COPYRIGHT HOLDER\n"
    @out << "# This file is distributed under the same license as the PACKAGE package.\n"
    @out << "# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.\n"
    @out << "#\n"
    @out << "#, fuzzy\n"
    @out << "msgid \"\"\n"
    @out << "msgstr \"\"\n"
    @out << "\"Project-Id-Version: PACKAGE VERSION\\n\"\n"
    @out << "\"POT-Creation-Date: #{time}\\n\"\n"
    @out << "\"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\n\"\n"
    @out << "\"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\n\"\n"
    @out << "\"Language-Team: LANGUAGE <LL@li.org>\\n\"\n"
    @out << "\"MIME-Version: 1.0\\n\"\n"
    @out << "\"Content-Type: text/plain; charset=UTF-8\\n\"\n"
    @out << "\"Content-Transfer-Encoding: 8bit\\n\"\n"
    @out << "\"Plural-Forms: nplurals=INTEGER; plural=EXPRESSION;\\n\"\n"
  end

  def generate_pot(ary)
    result = Array.new
    ary.each do |key|
      msgid = key.shift
      curr_pos = MAX_LINE_LEN
      key.each do |e|
        if curr_pos + e.size > MAX_LINE_LEN
          @out << "\n#:"
          curr_pos = 3
        else
          curr_pos += (e.size + 1)
        end
        @out << " " << e
      end
      msgid.gsub!(/"/, '\"')
      msgid.gsub!(/\r/, '')
      if msgid.include?("\000")
        ids = msgid.split(/\000/)
        @out << "\nmsgid \"" << ids[0] << "\"\n"
        @out << "msgid_plural \"" << ids[1] << "\"\n"
        @out << "msgstr[0] \"\"\n"
        @out << "msgstr[1] \"\"\n"
      else
        @out << "\nmsgid \"" << msgid << "\"\n"
        @out << "msgstr \"\"\n"
      end
    end
  end
  
  def print_help
    printf _("Usage: %s input.rb -o output.pot\n"), $0
    print _("Extract translatable strings from given input files.\n\n")
  end

  def check_options
    command_options = [
      ['--help', '-h', GetoptLong::NO_ARGUMENT], #'print this help and exit'],
      ['--version', '-v', GetoptLong::NO_ARGUMENT], #'print version info and exit'],
      ['--output', '-o', GetoptLong::REQUIRED_ARGUMENT]#, ['FILE', 'write output to specified file']]
    ]
    
    parser = GetoptLong.new
    parser.set_options(*command_options)
    
    opt = Hash.new
    parser.each do |name, arg|
      opt.store(name.sub(/^--/, ""), arg || true)
    end
    
    if opt['version']
      print "#{$0} #{VERSION.join('.')} \(#{DATE}\)\n\n"
      exit
    end
    
    if opt['help']
      print_help
      exit
    end
    
    opt
  end

  def set_output(opt)
    if opt['output']
      unless FileTest.exist? opt['output']
        @out = File.new(File.expand_path(opt['output']), "w+")
      else
        if $>.tty?
          # FIXME
          printf $stderr, "File '#{opt['output']}' already exists\n"
          exit 1
        else
          printf $stderr, "File '#{opt['output']}' already exists"
          exit 1
        end
      end
    else
      @out = STDOUT
    end
  end    
end  # class RGettext

if __FILE__ == $0 # in case we want to start it from somewhere else
  rgettext = RGettext.new
  rgettext.start
end
