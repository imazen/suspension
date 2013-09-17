module Suspension
  class TextReplayer

    attr_accessor :from_text, :to_text, :from_tokens, :to_tokens, :diff_algorithm

    # @param[String] from_text old version of text, with tokens
    # @param[String] to_text new version of text, with or without tokens
    # @param[Array<Token>, optional] from_tokens tokens to be suspended from
    #     from_text, defaults to REPOSITEXT_TOKENS
    # @param[Array<Token>, optional] to_tokens tokens to be suspended from
    #     to_text, defaults to REPOSITEXT_TOKENS
    # @param[Proc] diff_algorithm The diff algo, accepts two params (strings to compare)
    #              defaults to DiffMatchPatch
    def initialize(from_text, to_text, from_tokens = nil, to_tokens = nil, diff_algorithm = nil)
      @from_text = from_text
      @to_text = to_text
      @to_tokens = to_tokens || from_tokens
      @from_tokens = from_tokens || Suspension::REPOSITEXT_TOKENS
      @diff_algorithm = diff_algorithm || DiffAlgorithm.new
    end

    # Returns a document that contains to_text's filtered_text and from_text's
    # tokens.
    def replay
      from = Suspender.new(from_text, from_tokens).suspend
      to = Suspender.new(to_text, to_tokens).suspend

      # Diff filtered text from both files
      diff = diff_algorithm.call(from.filtered_text, to.filtered_text)

      # Adjust target file tokens based on diff
      adjusted_from_tokens = from.suspended_tokens.adjusted_for_diff(diff)

      # Merge `to` filtered_text with adjusted `from` tokens
      Unsuspender.new(to.filtered_text, adjusted_from_tokens).restore
    end

  end
end
