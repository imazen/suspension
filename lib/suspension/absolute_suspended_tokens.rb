module Suspension
  class AbsoluteSuspendedTokens < Array

    # Returns copy of self, adjusted for deletions
    # @param[Array<Array>] deletions as as array of start/end pairs: [[0,3], [8,12], ...]
    # @param[AbsoluteTokens] a copy of self, adjusted for deletions
    def with_deletions(deletions)
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
    # @param[Symbol] affinity, one of :left, :right
    # @param[AbsoluteTokens] a copy of self, adjusted for insertions
    def with_insertions(insertions, affinity = :left)
      assert_ordered_list_of_start_end_pairs(insertions)
      unless [:left, :right].include?(affinity)
        raise "Unrecognized affinity value #{ affinity.inspect }"
      end
      AbsoluteSuspendedTokens.new(
        self.map { |token|
          token = token.dup
          # Accumulate all insertions prior to (or overlapping) the token
          token.position += insertions.reduce(0) { |pos_offset, ins|
            if(
              (affinity == :left && ins[0] < token.position) || \
              (affinity == :right && ins[0] <= token.position)
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
        raise "All members must be of type SuspendedTokens. #{ entries.inspect }"
      end
      if reduce(0){ |pos_memo, e| e.position >= pos_memo ? e.position : false } === false
        raise  "Suspended Tokens must be in ascending order. #{ entries.inspect }"
      end
      self
    end

    # Returns copy of self with entries sorted stabily
    # @return[AbsoluteTokens] sorted copy of self with secondary sorting key
    #                         for suspended_tokens with identical position
    def stable_sort
      n = 0
      AbsoluteSuspendedTokens.new(sort_by{ |x| n += 1; [x.position, n] })
    end

  private

    # Raises exception if diff_list doesn't meet expectations:
    # [[0,3], [8,12], ...]
    def assert_ordered_list_of_start_end_pairs(diff_list)
      if(
        diff_list.any? { |a| a.length != 2 } || \
        diff_list.flatten.reduce(0){ |memo, e| e >= memo ? e : false } === false
      )
        raise "Array of ordered start/end pairs expected"
      end
    end

  end
end
