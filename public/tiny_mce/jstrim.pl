#! /usr/bin/perl -w

jsTrim("tiny_mce_src.js", "tiny_mce.js");
jsTrim("themes/simple/editor_template_src.js", "themes/simple/editor_template.js");
jsTrim("themes/default/editor_template_src.js", "themes/default/editor_template.js");
jsTrim("themes/advanced/editor_template_src.js", "themes/advanced/editor_template.js");
jsTrim("plugins/advhr/editor_plugin_src.js", "plugins/advhr/editor_plugin.js");
jsTrim("plugins/advimage/editor_plugin_src.js", "plugins/advimage/editor_plugin.js");
jsTrim("plugins/advlink/editor_plugin_src.js", "plugins/advlink/editor_plugin.js");
jsTrim("plugins/linkattach/editor_plugin_src.js", "plugins/linkattach/editor_plugin.js");
jsTrim("plugins/emotions/editor_plugin_src.js", "plugins/emotions/editor_plugin.js");
jsTrim("plugins/flash/editor_plugin_src.js", "plugins/flash/editor_plugin.js");
jsTrim("plugins/iespell/editor_plugin_src.js", "plugins/iespell/editor_plugin.js");
jsTrim("plugins/insertdatetime/editor_plugin_src.js", "plugins/insertdatetime/editor_plugin.js");
jsTrim("plugins/preview/editor_plugin_src.js", "plugins/preview/editor_plugin.js");
jsTrim("plugins/print/editor_plugin_src.js", "plugins/print/editor_plugin.js");
jsTrim("plugins/save/editor_plugin_src.js", "plugins/save/editor_plugin.js");
jsTrim("plugins/searchreplace/editor_plugin_src.js", "plugins/searchreplace/editor_plugin.js");
jsTrim("plugins/zoom/editor_plugin_src.js", "plugins/zoom/editor_plugin.js");
jsTrim("plugins/table/editor_plugin_src.js", "plugins/table/editor_plugin.js");
jsTrim("plugins/contextmenu/editor_plugin_src.js", "plugins/contextmenu/editor_plugin.js");
jsTrim("plugins/paste/editor_plugin_src.js", "plugins/paste/editor_plugin.js");
jsTrim("plugins/fullscreen/editor_plugin_src.js", "plugins/fullscreen/editor_plugin.js");
jsTrim("plugins/directionality/editor_plugin_src.js", "plugins/directionality/editor_plugin.js");
sub jsTrim {
	my $inFile = $_[0];
	my $outFile = $_[1];
	my $comment = '';
	my $content = '';

	# Load input file
	open(FILE, "<$inFile");
	undef $/;
	$content = <FILE>;
	close(FILE);

	if ($content =~ s#^\s*(/\*.*?\*/)##s or $content =~ s#^\s*(//.*?)\n\s*[^/]##s) {
	  $comment = "$1\n";
	}

	local $^W;

	# removing C/C++ - style comments:
	$content =~ s#/\*[^*]*\*+([^/*][^*]*\*+)*/|//[^\n]*|("(\\.|[^"\\])*"|'(\\.|[^'\\])*'|.[^/"'\\]*)#$2#gs;

	# save string literals
	my @strings = ();
	$content =~ s/("(\\.|[^"\\])*"|'(\\.|[^'\\])*')/push(@strings, "$1");'__CMPRSTR_'.$#strings.'__';/egs;

	# remove C-style comments
	$content =~ s#/\*.*?\*/##gs;
	# remove C++-style comments
	$content =~ s#//.*?\n##gs;
	# removing leading/trailing whitespace:
	#$content =~ s#(?:(?:^|\n)\s+|\s+(?:$|\n))##gs;
	# removing newlines:
	#$content =~ s#\r?\n##gs;

	# removing other whitespace (between operators, etc.) (regexp-s stolen from Mike Hall's JS Crunchinator)
	$content =~ s/\s+/ /gs;         # condensing whitespace
	#$content =~ s/^\s(.*)/$1/gs;    # condensing whitespace
	#$content =~ s/(.*)\s$/$1/gs;    # condensing whitespace
	$content =~ s/\s([\x21\x25\x26\x28\x29\x2a\x2b\x2c\x2d\x2f\x3a\x3b\x3c\x3d\x3e\x3f\x5b\x5d\x5c\x7b\x7c\x7d\x7e])/$1/gs;
	$content =~ s/([\x21\x25\x26\x28\x29\x2a\x2b\x2c\x2d\x2f\x3a\x3b\x3c\x3d\x3e\x3f\x5b\x5d\x5c\x7b\x7c\x7d\x7e])\s/$1/gs;

	# restore string literals
	$content =~ s/__CMPRSTR_([0-9]+)__/$strings[$1]/egs;

	# Write to ouput file
	open(FILE, ">$outFile");
	flock(FILE, 2);
	seek(FILE, 0, 2);
	print FILE $comment, $content;
	close(FILE);
}
