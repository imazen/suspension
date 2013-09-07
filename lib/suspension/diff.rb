module Suspension
  module Diff

    # Converts diff_match_patch_list from dmp format to ...
    # @param[Array<Array>] diff_match_patch_list Nested array in the form
    #             [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    #             See https://code.google.com/p/google-diff-match-patch/wiki/API
    # @param[-1,0,1] segment_type -1 for deletion, 0 for equality, 1 for insertion
    # @return[Array<Array>] Nested array of absolute start/stop values in the form
    #             [[10,22]] or [[10,23]].
    #             Deletions are relative to original text. Insertions are
    #             relative to text with deletions already applied.
    def self.convert_diff_match_patch(diff_match_patch_list, segment_type)
      dmp = diff_match_patch_list
      if dmp.any? { |p| !([-1,0,1].include?(p[0]) && p[1].is_a?(String)) }
        raise "diff_match_patch_list must contain an array of number/text pairs. #{dmp.inspect} "
      end
      # TODO: Test for valid segment_type argument: -1, 1. Is 0 allowed?
      subset = dmp.reduce([0,[]]) do |result, segment|
        # Accumulate all matching segments
        result[1] << [result[0], result[0] + segment[1].length] if segment[0] == segment_type
        # Increment position counter - except for opposite segment type
        result[0] += segment[1].length unless segment[0] == segment_type * -1
        result
      end
      subset[1]
    end

    # Returns just the deletions from diff_match_patch_list
    # @param[Array<Array>] diff_match_patch_list Nested array in the form
    #             [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    #             See https://code.google.com/p/google-diff-match-patch/wiki/API
    def self.extract_deletions(diff_match_patch_list)
      convert_diff_match_patch(diff_match_patch_list, -1)
    end

    # @param[Array<Array>] diff_match_patch_list Nested array in the form
    #             [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    #             See https://code.google.com/p/google-diff-match-patch/wiki/API
    def self.extract_insertions(diff_match_patch_list)
      convert_diff_match_patch(diff_match_patch_list, 1)
    end

    private_class_method :convert_diff_match_patch

  end

end
