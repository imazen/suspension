module Suspension
  class Unsuspender < Struct.new(:filtered_text, :suspended_tokens)

    attr_reader :output_text

    # Restores the suspended tokens back into their original locations in filtered_text
    # If an array of token_names is specified, only tokens with matching names will be restored - others will be discarded
    def restore (token_names)
      #Convert token names to symbols
      token_names = token_names.map(&:to_sym) if token_names
      #Ensure suspended tokens are in absolute form so they can safely be filtered
      suspended_tokens = suspended_tokens.to_absolute if suspended_tokens.is_a? RelativeSuspendedTokens
      #Filter suspended tokens
      token_subset = token_names.nil? ? suspended_tokens : suspended_tokens.select {|t| token_names.include? t.name }


      @output_text = ""
      last_token = 0
      last_position_validate = nil
      for token in token_subset
        @output_text += @filtered_text[last_token..token.position]
        last_token = token.position - last_token
        @output_text += token.contents
        raise "Suspended Tokens Out Of Order at #{token.position}" if last_position_validate && last_position_validate > token.position
        last_position_validate = token.position
      end
      @output_text += filtered_text[last_token..-1]
      @output_text
    end

  end 
end