require 'suspension/token'

module Suspension

  # Notes
  # =====
  #
  # Beginning of line works differently in StringScanner
  # ----------------------------------------------------
  #
  # The `^` matcher for beginning of line doesn't work with StringScanner.
  # It will match any occurrence, even if not at beginning of line since at time
  # of scan, the char will be at the beginning of the string to be scanned. We use
  # StringScanner#beginning_of_line? (aka #bol?) to detect if current match
  # position is at beginning of line. So instead of adding `^` to the regex, you
  # have to set the `must_be_start_of_line` flag to true.
  #
  # Consumption of trailing whitespace
  # ----------------------------------
  #
  # * Block tokens consume any trailing whitespace up to and including the final
  #   new line.
  # * Span tokens don't consume any trailing whitespace

  # Regex helpers
  # INDENT = /^(?:\t| {4})/
  OPT_SPACE = / {0,3}/ # Regexp for matching the optional space (zero to three spaces)
  SPACES_NEWLINE = /\s*?\n/ # matches optional spaces + a newline

  ALD_ANY_CHARS = /\\\}|[^\}]/
  ALD_ID_CHARS = /[\w-]/
  ALD_ID_NAME = /\w#{ALD_ID_CHARS}*/
  ALD = /#{OPT_SPACE}\{:(#{ALD_ID_NAME}):(#{ALD_ANY_CHARS}+)\}#{SPACES_NEWLINE}/ # called ALD_START in kramdown

  EXT_START = /\{::(comment|nomarkdown|options)#{ALD_ANY_CHARS}*?/
  EXT_WITH_BODY = /#{EXT_START}\}#{ALD_ANY_CHARS}*?\{:\/\1?\}/
  EXT_WITHOUT_BODY = /#{EXT_START}\/\}/

  IAL = /\{:#{ALD_ANY_CHARS}*?\}/

  # TODO: Both LINK_..._ANY_CHARS are naive implementations that don't allow for
  # unescaped brackets or parens in title or url.
  LINK_TEXT_ANY_CHARS = /\\\]|[^\]]/
  LINK_URL_ANY_CHARS = /\\\)|[^\)]/

  # Initialize tokens with :name, :regex, :must_be_start_of_line, :is_plain_text
  # Keep this set as small as possible to make it easy to reason about.
  # Don't consume any trailing whitespace to avoid interference with token regexes
  PLAIN_TEXT_TOKENS = [
    [:plain_text, /[a-zA-Z0-9][a-zA-Z0-9,\"\' ]*[a-zA-Z0-9]/, false, true]
  ].map { |e| Token.new(*e) }

  AT_SPECIFIC_TOKENS = [
    [:gap_mark, /%/],
    [:record, /\^\^\^\s*?\n?#{IAL}?#{SPACES_NEWLINE}/, true], # Note: the first \s*?\n? can't be replaced with SPACES_NEWLINE since space and \n are independent in this case.
    [:subtitle_mark, /@/]
  ].map { |e| Token.new(*e) }

  KRAMDOWN_SUBSET_TOKENS = [
    # define horizontal_rule before emphasis. Otherwise '***' will be parsed as
    # two emphasis tokens ('**' and '*')
    [:horizontal_rule, /#{OPT_SPACE}(\*|-|_)[ \t]*\1[ \t]*\1(\1|[ \t])*\n/, true],
    [:emphasis, /(\*\*?)|(__?)/],
    # Define extension_block before extension_span since it is more specific
    # We define both so that we can consume trailing whitespace on block according
    # to conventions.
    # Note on block: can't use any parentheses to remove SPACES_NEWLINE duplication
    # since that would break the \1 backreference in EXT_WITH_BODY
    [:extension_block, /#{EXT_WITH_BODY}#{SPACES_NEWLINE}|#{EXT_WITHOUT_BODY}#{SPACES_NEWLINE}/, true],
    [:extension_span, /#{EXT_WITH_BODY}|#{EXT_WITHOUT_BODY}/],
    # Define ial_block before ial_span since it is more specific
    [:ial_block, /#{IAL}#{SPACES_NEWLINE}/, true],
    [:ial_span, /#{IAL}/],
    # sorted alphabetically
    [:ald, ALD, true],
    [:header_atx, /\#{1,6}/, true],
    [:header_id, /\s\{\##{ALD_ID_NAME}\}/], # Spec requires at least one leading space
    [:header_setext, /#{OPT_SPACE}(-|=)+#{SPACES_NEWLINE}/, true],
    [:image, /!\[#{LINK_TEXT_ANY_CHARS}+\]\(#{LINK_URL_ANY_CHARS}*?\)/]
  ].map { |e| Token.new(*e) }

  # Order the tokens so that most common regexes are first to improve performance
  # of Suspender.suspend where we iterate over all tokens until we find a match.
  REPOSITEXT_TOKENS = PLAIN_TEXT_TOKENS + AT_SPECIFIC_TOKENS + KRAMDOWN_SUBSET_TOKENS

end
