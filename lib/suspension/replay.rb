module Suspension
  class TextReplayer < Struct.new(:from_text, :to_text, :from_tokens, :to_tokens, :diff_algorithm)

    def replay
        diff_algorithm ||= Proc.new { |a,b|
            DiffMatchPatch.new.diff_main(a,b)
        }

        from_tokens ||= Suspension.REPOSITEXT_TOKENS
        to_tokens ||= from_tokens

        from = Suspender.new(from_text,from_tokens).suspend
        to = Suspender.new(to_text,to_tokens)

        #Diff filtered text form both files
        diff = diff_algorithm(from.filtered_text,to.filtered_text)

        #Adjust target file tokens based on diff
        adjusted_tokens = to.suspended_tokens.with_deletions(Diff.extract_deletions(diff)).with_additions(Diff.extract_additions(diff))

        #Merge source file with target file tokens
        Unsuspender.new(from.filtered_text,adjusted_tokens).restore
    end 

  end

  class TokenReplacer < Struct.new(:from_text, :to_text, :from_tokens, :to_tokens)
    #Requires an array of the token names to transfer/replace
    def replace which_tokens
        #Suspend both
        from = Suspender.new(from_text,from_tokens).suspend
        to = Suspender.new(to_text,to_tokens).suspend
        raise "Text does not match. Run replay to->from first" unless from.filtered_text == to.filtered_text
        #Remove 'which_tokens' from the target file, replacing them with tokens from the source file.
        new_tokens = to.suspended_tokens.reject {|t| which_tokens.include?(t.name) } + from.suspended_tokens.select {|t| which_tokens.include?(t.name)}
        #Sort the tokens correctly so they can be applied
        new_tokens = AbsoluteSuspendedTokens.new(new_tokens).stable_sort
        #Regenerate the file
        Unsuspender.new(to.filtered_text, new_tokens).restore

    end 
  end
end