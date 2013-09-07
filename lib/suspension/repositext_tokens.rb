require 'suspension/token'

module Suspension

  REPOSITEXT_TOKENS = [
    Token.new(:record, /^\^\^\^\s*?(\{:(\\\}|[^\}]+)\})?\s*?\n/),
    Token.new(:escaped_character, /\\[\\@%]/, true), # Should permit backslash-escaped characters
    Token.new(:subtitle_mark, /@/),
    Token.new(:subtitle_mark, /%/)
  ]

end
