module Suspension
  module DiffExtractor

    # Returns just the deletions from diff_match_patch_list
    # @param[Array<Array>] diff_match_patch_list Nested array in the form
    #             [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    #             See https://code.google.com/p/google-diff-match-patch/wiki/API
    # @return[?] same as convert_diff_match_patch
    def self.extract_deletions(diff_match_patch_list)
      convert_diff_match_patch(diff_match_patch_list, -1)
    end

    # @param[Array<Array>] diff_match_patch_list Nested array in the form
    #             [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    #             See https://code.google.com/p/google-diff-match-patch/wiki/API
    # @return[?] same as convert_diff_match_patch
    def self.extract_insertions(diff_match_patch_list)
      convert_diff_match_patch(diff_match_patch_list, 1)
    end

  private

    # Converts diff_match_patch_list from dmp format to ...
    # @param[Array<Array>] diff_match_patch_list Nested array in the form
    #             [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    #             See https://code.google.com/p/google-diff-match-patch/wiki/API
    # @param[-1,0,1] segment_type -1 for deletion, 1 for insertion
    # @return[Array<Array>] Nested array of absolute start/stop values in the form
    #             [[10,22],...] where the first number is the start position and
    #             the second number is the end position of the segment.
    #             Deletions are relative to original text. Insertions are
    #             relative to text with deletions already applied.
    def self.convert_diff_match_patch(diff_match_patch_list, segment_type)
      dmp = diff_match_patch_list
      if dmp.any? { |p| !([-1,0,1].include?(p[0]) && p[1].is_a?(String)) }
        raise(
          DmpNumberTextPairTypeError,
          "diff_match_patch_list must contain an array of number/text pairs. #{ dmp.inspect }"
        )
      end
      if ![-1,1].include?(segment_type)
        raise(
          DmpSegmentTypeError,
          "segment_type must be one of -1 or 1. #{ segment_type.inspect }"
        )
      end
      subset_for_segment_type = dmp.reduce([0,[]]) do |result, dmp_segment|
        e_seg_type, e_seg_text = dmp_segment
        # Collect all segments of given segment_type
        if e_seg_type == segment_type
          result[1] << [result[0], result[0] + e_seg_text.length]
        end
        # Increment position counter for segments of types
        # segment_type and equality (0)
        if [segment_type, 0].include?(e_seg_type)
          result[0] += e_seg_text.length
        end
        result
      end
      subset_for_segment_type[1]
    end

  end

end
