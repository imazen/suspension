module Suspension
  class TextReplayer

    attr_accessor :doc_a_text, :doc_b_tokens, :tokens_a, :tokens_b, :diff_algorithm

    # @param[String] doc_a_text document that provides the authoritative text.
    # @param[String] doc_b_tokens document that provides the authoritative tokens.
    # @param[Array<Token>, optional] tokens_a tokens to be suspended from
    #     doc_a_text, defaults to REPOSITEXT_TOKENS.
    # @param[Array<Token>, optional] tokens_b tokens to be suspended from
    #     doc_b_tokens, defaults to REPOSITEXT_TOKENS.
    # @param[Proc] diff_algorithm The diff algo, accepts two params (strings to compare)
    #              defaults to DiffAlgorithm
    def initialize(doc_a_text, doc_b_tokens, tokens_a = nil, tokens_b = nil, diff_algorithm = nil)
      @doc_a_text = doc_a_text
      @doc_b_tokens = doc_b_tokens
      @tokens_a = tokens_a || Suspension::REPOSITEXT_TOKENS
      @tokens_b = tokens_b || @tokens_a
      @diff_algorithm = diff_algorithm || DiffAlgorithm.new
    end

    # Returns a document that contains doc_b_tokens' tokens and doc_a_text's
    # filtered_text.
    def replay
      text_authority = Suspender.new(doc_a_text, tokens_a).suspend
      token_authority = Suspender.new(doc_b_tokens, tokens_b).suspend

      # Diff filtered text from both files
      diff = diff_algorithm.call(token_authority.filtered_text, text_authority.filtered_text)

      # Adjust token_authority's token offsets based on diff
      adjusted_authoritative_tokens = token_authority.suspended_tokens.adjust_for_diff(diff)

      # Merge text_authority's filtered_text with token_authority's adjusted tokens
      Unsuspender.new(text_authority.filtered_text, adjusted_authoritative_tokens).restore
    end

  end
end
