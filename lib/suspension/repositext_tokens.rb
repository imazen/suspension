require 'suspension/token'

module Suspension

  # Regex helpers
  INDENT = /^(?:\t| {4})/
  OPT_SPACE = / {0,3}/ # Regexp for matching the optional space (zero or up to three spaces)

  ALD_ANY_CHARS = /\\\}|[^\}]/
  ALD_ID_CHARS = /[\w-]/
  ALD_ID_NAME = /\w#{ALD_ID_CHARS}*/
  ALD = /^#{OPT_SPACE}\{:(#{ALD_ID_NAME}):(#{ALD_ANY_CHARS}+)\}\s*?\n/ # called ALD_START in kramdown

  EXT_START = /\{::(comment|nomarkdown|options)#{ALD_ANY_CHARS}*?/
  EXT_WITH_BODY = /#{EXT_START}\}#{ALD_ANY_CHARS}*?\{:\/\1?\}/
  EXT_WITHOUT_BODY = /#{EXT_START}\/\}/

  IAL = /\{:#{ALD_ANY_CHARS}*?\}/

  # Initialize tokens with :name, :regex, :is_plain_text
  AT_SPECIFIC_TOKENS = [
    [:gap_mark, /%/],
    [:record, /^\^\^\^\s*?#{IAL}?\s*?\n/],
    [:subtitle_mark, /@/]
  ].map { |e| Token.new(*e) }

  KRAMDOWN_SUBSET_TOKENS = [
    [:ald, ALD],
    [:atx_header, /^\#{1,6}/],
    [:blank_line, "\n\n\n"],
    [:emphasis, /(\*\*?)|(__?)/],
    [:extension, /#{EXT_WITH_BODY}|#{EXT_WITHOUT_BODY}/],
    [:header_id, /\{\##{ALD_ID_NAME}\}/],
    [:horizontal_rule, /^#{OPT_SPACE}(\*|-|_)[ \t]*\1[ \t]*\1(\1|[ \t])*\n/],
    [:ial, IAL],
    [:setext_header, /^(-|=)+\s*?\n/]
  ].map { |e| Token.new(*e) }

  REPOSITEXT_TOKENS = AT_SPECIFIC_TOKENS + KRAMDOWN_SUBSET_TOKENS

end
