module Suspension
  class TokenRemover

    attr_accessor :doc_with_tokens, :tokens_to_remove

    # @param[String] doc_with_tokens document that contains tokens to be removed.
    # @param[Array<Token>, optional] tokens_to_remove tokens to be removed from
    #     doc_with_tokens, defaults to AT_SPECIFIC_TOKENS.
    # @param[String] doc_with_tokens, with tokens_to_remove removed.
    def initialize(doc_with_tokens, tokens_to_remove = nil)
      @doc_with_tokens = doc_with_tokens
      @tokens_to_remove = tokens_to_remove || Suspension::AT_SPECIFIC_TOKENS
    end

    # Returns a copy of doc_with_tokens, with tokens_to_remove removed.
    def remove
      from = Suspender.new(doc_with_tokens, tokens_to_remove).suspend
      from.filtered_text
    end

  end
end
