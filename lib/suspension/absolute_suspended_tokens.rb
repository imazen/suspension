module Suspension

  # Represents a set of suspended tokens with absolute position information.
  class AbsoluteSuspendedTokens < Array

    # Adjusts tokens based on diff
    # @param[Array<Array>] diff a dmp list of the following form:
    #     [[-1, "a"], [0, "ab"], [-1, "b"], [1, "x"], [0, "ccnn"], [1, "e"]]
    # @return[AbsoluteSuspendedTokens] a copy of self, adjustd for diff
    def adjust_for_diff(diff)
      adjust_for_deletions(DiffExtractor.extract_deletions(diff)) \
          .adjust_for_insertions(DiffExtractor.extract_insertions(diff))
    end

    # Returns copy of self, adjusted for deletions
    # @param[Array<Array>] deletions as as array of start/end pairs: [[0,3], [8,12], ...]
    # @param[AbsoluteSuspendedTokens] a copy of self, adjusted for deletions
    def adjust_for_deletions(deletions)
      assert_ordered_list_of_start_end_pairs(deletions)
      AbsoluteSuspendedTokens.new(
        map { |token|
          token = token.dup
          # Accumulate all deletions prior to (or overlapping) the token
          token.position -= deletions.reduce(0) { |pos_offset, del|
            if del[0] < token.position
              pos_offset + [token.position - del[0], del[1] - del[0]].min
            else
              pos_offset
            end
          }
          token
        }
      )
    end

    # Returns copy of self, adjusted for insertions
    # @param[Array<Array>] insertions as array of start/end pairs: [[0,3], [8,12], ...]
    # @param[Symbol, optional] affinity, one of :left, :right, or reasonable default if nil.
    # @param[AbsoluteSuspendedTokens] a copy of self, adjusted for insertions
    def adjust_for_insertions(insertions, affinity = nil)
      assert_ordered_list_of_start_end_pairs(insertions)
      unless [:left, :right, nil].include?(affinity)
        raise "Unrecognized affinity value #{ affinity.inspect }"
      end
      AbsoluteSuspendedTokens.new(
        map { |token|
          token = token.dup
          affinity ||= :right
          # Accumulate all insertions prior to (or overlapping) the token
          token.position += insertions.reduce(0) { |pos_offset, ins|
            # Update ref_pos so that we can include insertions that would prior
            # to adjustment be after token.position.
            ref_pos = token.position + pos_offset
            if(
              (affinity == :left && ins[0] < ref_pos) || \
              (affinity == :right && ins[0] <= ref_pos)
            )
              pos_offset + ins[1] - ins[0]
            else
              pos_offset
            end
          }
          token
        }
      )
    end

    # Converts self to a list of relative suspended tokens.
    # @return[RelativeSuspendedTokens]
    def to_relative
      last_position = 0
      RelativeSuspendedTokens.new(
        map { |abs_suspended_token|
          rel_suspended_token = abs_suspended_token.dup
          rel_suspended_token.position -= last_position
          last_position = abs_suspended_token.position
          rel_suspended_token
        }
      ).validate
    end

    # Validates self, raises exceptions as needed
    # @return[AbsoluteSuspendedTokens] self
    def validate
      if any? { |e| !e.is_a?(SuspendedToken) }
        raise(TokenTypeError, "All members must be of type SuspendedTokens. #{ entries.inspect }")
      end
      if reduce(0){ |pos_memo, e| e.position >= pos_memo ? e.position : false } === false
        raise(TokensNotAscendingError, "Suspended Tokens must be in ascending order. #{ entries.inspect }")
      end
      self
    end

    # Returns copy of self with entries sorted by position, retaining the current
    # sort order for items with the same position.
    # @return[AbsoluteSuspendedTokens] sorted copy of self with secondary sorting key
    #                         for suspended_tokens with identical position
    def stable_sort
      n = 0
      AbsoluteSuspendedTokens.new(sort_by{ |x| n += 1; [x.position, n] })
    end

  private

    # Raises exception if diff_list doesn't meet expectations:
    # * all items are tuples
    # * all start/end positions are in ascending order
    # [[0,3], [8,12], ...]
    def assert_ordered_list_of_start_end_pairs(diff_list)
      if diff_list.any? { |a| a.length != 2 }
        raise(StartEndPairsTypeError, "Array of start/end pairs expected")
      end
      diff_list.flatten.reduce(0){ |memo, e|
        if e >= memo
          e
        else
          raise(StartEndPairsNotAscendingError, "Array of start/end pairs is not ordered")
        end
      }
    end

  end
end
