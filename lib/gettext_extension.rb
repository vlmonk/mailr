require 'gettext'
include GetText # we want to be able to translate everywhere

module GetText
  # GetText has this behaviour that it saves the binding to the mo file
  # on a file by file basis. Every ruby file gets its own binding. We have to
	# override this behaviour because it doesn't make any sense for a web
	# application. We want one message catalog for all our files.
  module_function
  def callersrc; '*' end
end
