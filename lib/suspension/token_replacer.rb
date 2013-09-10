module Suspension
  class TokenReplacer < Struct.new(:from_text, :to_text, :from_tokens, :to_tokens)

    # Requires an array of the token names to transfer/replace
    def replace(which_tokens)
      #Suspend both
      from = Suspender.new(from_text, from_tokens).suspend
      to = Suspender.new(to_text, to_tokens).suspend
      if from.filtered_text != to.filtered_text
        raise "Text does not match. Run replay to->from first"
      end
      #Remove 'which_tokens' from the target file, replacing them with tokens from the source file.
      new_tokens = to.suspended_tokens.reject { |t| which_tokens.include?(t.name) } \
                   + from.suspended_tokens.select { |t| which_tokens.include?(t.name) }
      #Sort the tokens correctly so they can be applied
      new_tokens = AbsoluteSuspendedTokens.new(new_tokens).stable_sort
      #Regenerate the file
      Unsuspender.new(to.filtered_text, new_tokens).restore
    end

  end
end