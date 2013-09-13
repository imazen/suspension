require 'suspension/token'

module Suspension

  # Initialize tokens with :name, :regex, :is_plain_text
  AT_SPECIFIC_TOKENS = [
    # span tokens
    [:gap_mark, /%/],
    [:subtitle_mark, /@/],
    # block tokens
    [:record, /^\^\^\^\s*?(\{:(\\\}|[^\}]+)\})?\s*?\n/]
  ].map { |e| Token.new(*e) }

  KRAMDOWN_SUBSET_TOKENS = [
    # span tokens
    [:emphasis, "This *is* so **hard**."],
    [:span_extensions, "This is a {::comment}simple{:/} paragraph."],
    # block tokens
    [:atx_header, "# header"],
    [:blank_line, "\n\n\n"],
    [:block_extensions, "{::comment}\nThis is a comment {:/}which is {:/comment} ignored.\n{:/comment}"],
    [:horizontal_rule, "***"],
    [:paragraph, "This is just a normal paragraph."],
    [:setext_header, "header\n===="]
  ].map { |e| Token.new(*e) }

  REPOSITEXT_TOKENS = AT_SPECIFIC_TOKENS + KRAMDOWN_SUBSET_TOKENS

end
