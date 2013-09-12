module Suspension
  class TokenReplacer

    attr_accessor :from_text, :to_text, :from_tokens, :to_tokens

    # @param[String] from_text old version of text, with tokens
    # @param[String] to_text new version of text, with or without tokens
    # @param[Array<Token>, optional] from_tokens tokens to be suspended from
    #     from_text, defaults to REPOSITEXT_TOKENS
    # @param[Array<Token>, optional] to_tokens tokens to be suspended from
    #     to_text, defaults to REPOSITEXT_TOKENS
    def initialize(from_text, to_text, from_tokens = nil, to_tokens = nil)
      @from_text = from_text
      @to_text = to_text
      @from_tokens = from_tokens || Suspension.REPOSITEXT_TOKENS
      @to_tokens = to_tokens || from_tokens
    end

    # Returns a document that updates `which_token_names` in to_text based on
    # where they are located in `from_text`.
    # @param[Array<Symbol>] which_token_names an Array of token names to be
    #     replaced.
    def replace(which_token_names)
      # Suspend both texts
      from = Suspender.new(from_text, from_tokens).suspend
      to = Suspender.new(to_text, to_tokens).suspend
      if from.filtered_text != to.filtered_text
        raise ArgumentError, "Filtered text does not match. Run replay to->from first"
      end

      # Remove 'which_token_names' from 'from_text', replacing them with tokens
      # from 'to_text'.
      retained_tokens = from.suspended_tokens \
                            .reject { |t| which_token_names.include?(t.name) }
      updated_tokens = to.suspended_tokens \
                         .select { |t| which_token_names.include?(t.name) }
      # Sort the tokens correctly so they can be applied
      new_tokens = AbsoluteSuspendedTokens.new(
        retained_tokens + updated_tokens
      ).stable_sort
      # Regenerate the file
      Unsuspender.new(to.filtered_text, new_tokens).restore
    end

  end
end
