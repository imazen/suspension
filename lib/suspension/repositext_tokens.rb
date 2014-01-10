require 'suspension/token'

module Suspension

  # This module specifies the tokens that can be suspended from a document.
  #
  # Each token has the following attributes:
  #
  # * :name - the name of the token so that we can reason about it.
  # * :regex - the regex that will be used by StringScanner to consume a token.
  # * :must_be_start_of_line - set to true if the token must be located at the
  #   start of a line. We use this in lieu of '^' since it doesn't work with
  #   StringScanner.
  # * :is_plain_text - set to true if the match is considered plain text and
  #   should be added to filtered_text, rather than suspended. This feature
  #   exists for performance reasons only so that we can match long runs of
  #   plain text in StringScanner, rather than taking one character at a time
  #   if none of the other tokens matches.
  #
  # Order of tokens
  # ---------------
  #
  # The following factors determine the order of REPOSITEXT_TOKENS definitions:
  #
  # 1. regex specificity - put a more specific regex before a more general regex
  #    if the more general regex would match a string that should be parsed by
  #    the more specific one.
  # 2. Suspender#suspend performance - when we suspend a document, we iterate
  #    over all REPOSITEXT_TOKENS at every StringScanner match. We can increase
  #    performance if we put more common tokens first, so that we don't have
  #    to iterate over as many tokens.
  # 3. Given everything else is equal, we sort tokens alphabetically by their
  #    name.
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
  # Consumption of whitespace and \n
  # --------------------------------
  #
  # Conventions for consuming leading \n:
  #
  # * Block tokens consume leading \n if it exists. See note above BLOCK_START
  #   for details.
  # * Span tokens don't consume any leading \n
  #
  # Conventions for consuming trailing whitespace:
  #
  # * Block tokens consume any trailing whitespace up to and including the final new line.
  # * Span tokens don't consume any trailing whitespace

  # INDENT = /^(?:\t| {4})/ # We may need this if we support more kramdown features
  OPT_SPACE = / {0,3}/ # Regexp for matching optional space (zero to three spaces). Typically used at the start of a line.
  # Note: BLOCK_START matches an optional preceding \n. We want to include the
  # preceding \n with block level tokens to guarantee that after
  # suspension/unsuspension they are still located at the beginning of a line.
  # We need to make it optional, because there are a few valid scenarios where there
  # is no preceding \n before a block level element. Examples:
  # * `^^^` record token at beginning of file
  # * two subsequent block level elements without a blank line inbetween. In this
  #   case the first block level element's regex will consume it's trailing \n,
  #   leaving no leading \n for the second block level element.
  BLOCK_START = /\n?/
  BLOCK_END = /\s*?\n/ # matches optional spaces + a newline. Typically used at the end of a block token.

  ALD_ANY_CHARS = /\\\}|[^\}]/
  ALD_ID_CHARS = /[\w-]/
  ALD_ID_NAME = /\w#{ALD_ID_CHARS}*/
  ALD = /#{BLOCK_START}#{OPT_SPACE}\{:(#{ALD_ID_NAME}):(#{ALD_ANY_CHARS}+)\}#{BLOCK_END}/ # called ALD_START in kramdown

  EXT_START = /\{::(comment|nomarkdown|options)#{ALD_ANY_CHARS}*?/
  EXT_WITH_BODY = /#{EXT_START}\}#{ALD_ANY_CHARS}*?\{:\/\1?\}/
  EXT_WITHOUT_BODY = /#{EXT_START}\/\}/

  IAL = /\{:#{ALD_ANY_CHARS}*?\}/

  # TODO: Both LINK_..._ANY_CHARS are naive implementations that don't allow for
  # unescaped brackets or parens in title or url.
  LINK_TEXT_ANY_CHARS = /\\\]|[^\]]/
  LINK_URL_ANY_CHARS = /\\\)|[^\)]/

  # Keep this set as small as possible to make it easy to reason about.
  # Don't consume any trailing whitespace to avoid interference with token regexes
  PLAIN_TEXT_TOKENS = [
    [:plain_text, /[a-zA-Z0-9][a-zA-Z0-9,\"\' ]*[a-zA-Z0-9]/, false, true]
  ].map { |e| Token.new(*e) }

  AT_SPECIFIC_TOKENS = [
    [:gap_mark, /%/],
    # Note: the first \s*?\n? can't be replaced with BLOCK_LINE_END since space and \n are independent in this case.
    [:record, /#{BLOCK_START}#{OPT_SPACE}\^\^\^\s*?\n?#{IAL}?#{BLOCK_END}/, true],
    [:subtitle_mark, /@/]
  ].map { |e| Token.new(*e) }

  KRAMDOWN_SUBSET_TOKENS = [
    # define horizontal_rule before emphasis. Otherwise '***' will be parsed as
    # two emphasis tokens ('**' and '*')
    [:horizontal_rule, /#{BLOCK_START}#{OPT_SPACE}(\*|-|_)[ \t]*\1[ \t]*\1(\1|[ \t])*#{BLOCK_END}/, true],
    [:emphasis, /(\*\*?)|(__?)/],
    # Define extension_block before extension_span since it is more specific
    # We define both so that we can consume trailing whitespace on block according
    # to conventions.
    # Note on block: can't use any parentheses to remove BLOCK_END duplication
    # since that would break the \1 backreference in EXT_WITH_BODY
    [:extension_block, /#{BLOCK_START}#{EXT_WITH_BODY}#{BLOCK_END}|#{BLOCK_START}#{EXT_WITHOUT_BODY}#{BLOCK_END}/, true],
    [:extension_span, /#{EXT_WITH_BODY}|#{EXT_WITHOUT_BODY}/],
    # Define ial_block before ial_span since it is more specific
    [:ial_block, /#{BLOCK_START}#{IAL}#{BLOCK_END}/, true],
    [:ial_span, /#{IAL}/],
    # sorted alphabetically
    [:ald, ALD, true],
    [:header_atx, /#{BLOCK_START}\#{1,6}/, true],
    [:header_id, /\s\{\##{ALD_ID_NAME}\}/], # Spec requires at least one leading space
    [:header_setext, /#{BLOCK_START}#{OPT_SPACE}(-|=)+#{BLOCK_END}/, true],
    [:image, /!\[#{LINK_TEXT_ANY_CHARS}+\]\(#{LINK_URL_ANY_CHARS}*?\)/]
  ].map { |e| Token.new(*e) }

  REPOSITEXT_TOKENS = PLAIN_TEXT_TOKENS + AT_SPECIFIC_TOKENS + KRAMDOWN_SUBSET_TOKENS

end
