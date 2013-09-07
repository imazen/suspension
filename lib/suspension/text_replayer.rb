module Suspension
  class TextReplayer < Struct.new(:from_text, :to_text, :from_tokens, :to_tokens, :diff_algorithm)

    def replay
      diff_algorithm ||= Proc.new { |a,b| DiffMatchPatch.new.diff_main(a,b) }

      from_tokens ||= Suspension.REPOSITEXT_TOKENS
      to_tokens ||= from_tokens

      from = Suspender.new(from_text, from_tokens).suspend
      to = Suspender.new(to_text, to_tokens)

      # Diff filtered text form both files
      diff = diff_algorithm(from.filtered_text, to.filtered_text)

      # Adjust target file tokens based on diff
      adjusted_tokens = to.suspended_tokens \
                          .with_deletions(Diff.extract_deletions(diff)) \
                          .with_insertions(Diff.extract_insertions(diff))

      # Merge source file with target file tokens
      Unsuspender.new(from.filtered_text, adjusted_tokens).restore
    end

  end
end
