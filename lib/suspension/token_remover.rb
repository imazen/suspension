module Suspension
  class TokenRemover

    attr_accessor :text_with_tokens, :tokens_to_remove

    # @param[String] text_with_tokens the text that contains tokens to be removed
    # @param[Array<Token>, optional] tokens_to_remove tokens to be removed from
    #     text_with_tokens, defaults to AT_SPECIFIC_TOKENS
    # @param[String] text_with_tokens, with tokens_to_remove removed
    def initialize(text_with_tokens, tokens_to_remove = nil)
      @text_with_tokens = text_with_tokens
      @tokens_to_remove = tokens_to_remove || Suspension::AT_SPECIFIC_TOKENS
    end

    # Returns a copy of text_with_tokens, with tokens_to_remove removed.
    def remove
      from = Suspender.new(text_with_tokens, tokens_to_remove).suspend
      from.filtered_text
    end

  end
end
