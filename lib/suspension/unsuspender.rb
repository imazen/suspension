module Suspension
  class Unsuspender < Struct.new(:filtered_text, :suspended_tokens)

    attr_reader :output_text

    # Restores the suspended tokens back into their original locations in
    # filtered_text. If an array of token_names is specified, only tokens with
    # matching names will be restored - others will be discarded.
    # @param[Array<Symbol>, optional] token_names a list of token names to be
    #     restored. Defaults to suspended_tokens
    # @return[String] the restored text
    def restore(token_names = nil)
      # Ensure suspended tokens are in absolute form so they can safely be filtered
      token_subset = if suspended_tokens.is_a?(RelativeSuspendedTokens)
        suspended_tokens.validate.to_absolute
      else
        suspended_tokens.validate
      end

      if token_names
        # Convert token names to symbols
        token_names = token_names.map(&:to_sym)
        # Filter suspended tokens
        token_subset = token_subset.select { |t| token_names.include?(t.name) }
      end

      @output_text = ""
      last_token = 0
      token_subset.each { |token|
        @output_text += filtered_text[last_token..token.position-1]
        last_token = token.position
        @output_text += token.contents
      }
      @output_text += filtered_text[last_token..-1]
      @output_text
    end

  end
end
