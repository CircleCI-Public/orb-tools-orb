#!/usr/local/bin/ruby
# NOTE: this is a brute-force method that does straight string
# manipulation rather than parsing the YAML in order to preserve
# all comments and spacing exactly as the author wrote them (other
# than outdenting everything in the final string).
# This could probably be more elegant in various ways if you're
# interesting in refactoring...
require 'json'
require 'unindent'
file='<< parameters.source >>'
orb='<< parameters.orb >>'
lines = []
write_lines = false
inside_orbs_stanza = false
initial_indent = 0
debug = false
version = 'version: unknown'

File.readlines(file).each do |line|
    indent = line[/\A */].size
    if indent == 0 && line.slice(0, 5).downcase == "orbs:"
    inside_orbs_stanza = true
    next
    end
    if indent == 0 && line.slice(0, 8).downcase == "version:"
    version = line
    end
    # leaving this in for now because it's innocuous and useful.
    # The debug flag will be handy as the code stabilizes.
    if debug
    puts '------ LINE ---------'
    puts 'line: ' + line.to_s
    puts 'indent: ' + indent.to_s
    puts 'initial_indent: ' + initial_indent.to_s
    puts 'inside_orbs_stanza: ' + inside_orbs_stanza.to_s
    puts 'write_lines: ' + write_lines.to_s
    end
    # if we are writing lines we are looking for the end
    # and we are capturing even empty lines
    if write_lines
    # if this line has the same as the originating indent, we are done
    break if indent == initial_indent
    # write the line
    lines.push line
    end

    # if this is an empty line, skip ahead
    next if line.strip.empty?

    if inside_orbs_stanza
    # if this line has no indent it means we are no longer in the orbs stanza
    break if indent == 0
    ## if we are inside the orbs inside the orbs stanza
    ## but have not yet set the indent, it should mean
    ## the line we are on is the right initial indent
    if initial_indent == 0
        initial_indent = indent
    end
    puts line.slice(indent, orb.size) if debug
    write_lines = true if line.slice(indent, orb.size) == orb
    end
end
final = lines.join("").unindent.prepend(version + "\n")
puts "WRITING FILE: << parameters.file >>"
File.open(File.expand_path('<< parameters.file >>'), "w") { |file| file.write(final) }