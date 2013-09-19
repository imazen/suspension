require 'suspension/token'

module Suspension

  # Comments on regexen
  # * the `^` matcher for beginning of line doesn't work here since we use
  #   StringScanner. It will match any occurrence, even if not at beginning of
  #   line since at time of scan, the char will be at the beginning of the string
  #   to be scanned. We use StringScanner#beginning_of_line? (aka #bol?) to
  #   detect if current match position is at beginning of line. So instead of
  #   adding `^` to the regex, you have to set the `must_be_start_of_line`
  #   flag to true.

  # Regex helpers
  # INDENT = /^(?:\t| {4})/
  OPT_SPACE = / {0,3}/ # Regexp for matching the optional space (zero or up to three spaces)

  ALD_ANY_CHARS = /\\\}|[^\}]/
  ALD_ID_CHARS = /[\w-]/
  ALD_ID_NAME = /\w#{ALD_ID_CHARS}*/
  ALD = /#{OPT_SPACE}\{:(#{ALD_ID_NAME}):(#{ALD_ANY_CHARS}+)\}\s*?\n/ # called ALD_START in kramdown

  EXT_START = /\{::(comment|nomarkdown|options)#{ALD_ANY_CHARS}*?/
  EXT_WITH_BODY = /#{EXT_START}\}#{ALD_ANY_CHARS}*?\{:\/\1?\}/
  EXT_WITHOUT_BODY = /#{EXT_START}\/\}/

  IAL = /\{:#{ALD_ANY_CHARS}*?\}/

  # TODO: Both LINK_..._ANY_CHARS are naive implementations that don't allow for
  # unescaped brackets or parens in title or url.
  LINK_TEXT_ANY_CHARS = /\\\]|[^\]]/
  LINK_URL_ANY_CHARS = /\\\)|[^\)]/

  # Initialize tokens with :name, :regex, :must_be_start_of_line, :is_plain_text
  PLAIN_TEXT_TOKENS = [
    [:pt_lines, /[\w \.\;\-\!\?]+/, false, true],
    [:pt_blank_lines, /\n\n+/, false, true]
  ].map { |e| Token.new(*e) }

  AT_SPECIFIC_TOKENS = [
    [:gap_mark, /%/],
    [:record, /\^\^\^\s*?\n?#{IAL}?\s*?\n/, true],
    [:subtitle_mark, /@/]
  ].map { |e| Token.new(*e) }

  KRAMDOWN_SUBSET_TOKENS = [
    [:ald, ALD, true],
    [:emphasis, /(\*\*?)|(__?)/],
    [:extension, /#{EXT_WITH_BODY}|#{EXT_WITHOUT_BODY}/],
    [:header_atx, /\#{1,6}\s*/, true],
    [:header_id, /\{\##{ALD_ID_NAME}\}/],
    [:header_setext, /(-|=)+\s*?\n/, true],
    [:horizontal_rule, /#{OPT_SPACE}(\*|-|_)[ \t]*\1[ \t]*\1(\1|[ \t])*\n/, true],
    [:ial, /#{IAL}\s*?\n?/],
    [:image, /!\[#{LINK_TEXT_ANY_CHARS}+\]\(#{LINK_URL_ANY_CHARS}*?\)/]
  ].map { |e| Token.new(*e) }

  # Order the tokens so that most common regexes are first to improve performance
  # of Suspender.suspend where we iterate over all tokens until we find a match.
  REPOSITEXT_TOKENS = PLAIN_TEXT_TOKENS + AT_SPECIFIC_TOKENS + KRAMDOWN_SUBSET_TOKENS

end
