module Suspension
  class TokenReplacer

    attr_accessor :doc_a_tokens, :doc_b_text, :tokens_a, :tokens_b

    # @param[String] doc_a_tokens document that provides the authoritative tokens.
    # @param[String] doc_b_text document that provides the authoritative text.
    # @param[Array<Token>, optional] tokens_a tokens to be suspended from
    #     doc_a_tokens, defaults to REPOSITEXT_TOKENS.
    # @param[Array<Token>, optional] tokens_b tokens to be suspended from
    #     doc_b_text, defaults to REPOSITEXT_TOKENS.
    def initialize(doc_a_tokens, doc_b_text, tokens_a = nil, tokens_b = nil)
      @doc_a_tokens = doc_a_tokens
      @doc_b_text = doc_b_text
      @tokens_a = tokens_a || Suspension::REPOSITEXT_TOKENS
      @tokens_b = tokens_b || @tokens_a
    end

    # Returns a document that replaces `replaced_token_names` in `doc_b_text`
    # based on where they are located in `doc_a_tokens`. Retains all
    # `doc_b_text`'s other tokens that are not in `replaced_token_names`.
    # @param[Array<Symbol>] replaced_token_names an Array of token names to be
    #     replaced.
    # @return[String] document with replaced tokens
    def replace(replaced_token_names)
      # Suspend both texts
      token_authority = Suspender.new(doc_a_tokens, tokens_a).suspend
      text_authority = Suspender.new(doc_b_text, tokens_b).suspend
      if token_authority.filtered_text != text_authority.filtered_text
        raise ArgumentError, "Filtered text does not match. Run replay to->from first"
      end

      # Remove 'replaced_token_names' from 'doc_b_text', replacing them with tokens
      # from 'doc_a_tokens'.
      retained_tokens = text_authority \
                            .suspended_tokens \
                            .select { |t| !replaced_token_names.include?(t.name) }
      updated_tokens  = token_authority \
                            .suspended_tokens \
                            .select { |t| replaced_token_names.include?(t.name) }
      # Sort the tokens correctly so they can be applied
      # NOTE: it is important to add the updated_tokens first to achieve the
      # expected behavior.
      new_tokens = AbsoluteSuspendedTokens.new(
        updated_tokens + retained_tokens
      ).stable_sort
      # Regenerate the file
      Unsuspender.new(text_authority.filtered_text, new_tokens).restore
    end

  end
end
