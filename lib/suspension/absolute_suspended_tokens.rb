module Suspension

  # Represents a set of suspended tokens with absolute position information.
  class AbsoluteSuspendedTokens < Array

    # Adjusts tokens based on diff. This is used in TextReplayer where
    # we have to adjust absolute token positions based on text changes
    # (insertions and deletions).
    # @param diff [Array<Array>] a dmp list of the following form:
    #     [[-1, "a"], [0, "ab"], [-1, "b"], [1, "x"], [0, "ccnn"], [1, "e"]]
    # @return[AbsoluteSuspendedTokens] a copy of self, adjustd for diff
    def adjust_for_diff(diff)
      # Adjust for deletions first, then insertions.
      adjust_for_deletions(DiffExtractor.extract_deletions(diff))
        .adjust_for_insertions(DiffExtractor.extract_insertions(diff))
    end

    # Returns copy of self, with token positions adjusted for deletions.
    #  * Applies all deletions that start before a token's position.
    #  * Accumulates the offset from prior deletions and applies it to
    #    all later tokens.
    #  * Handles situations where tokens fall between the start and end
    #    of a deletion (overlapping deletions): Applies only partial
    #    offset.
    #  * Keeps track of latest deletion attrs to handle cases where
    #    multiple tokens fall inside of a single deletion.
    #  * Unlike #adjust_for_insertions, we don't need to keep track of
    #    adjusted_token_position. We can use recorded tokens' positions.
    #    This is because of the way start and end positions for deletions
    #    are tracked.
    #  * Iterates over deletions and tokens in parallel for improved
    #    performance.
    # @param deletions [Array<Array>] as as array of start/end pairs: [[0,3], [8,12], ...]
    # @return [AbsoluteSuspendedTokens] a copy of self, adjusted for deletions
    def adjust_for_deletions(deletions)
      assert_ordered_list_of_start_end_pairs(deletions)
      # Clone deletions queue before mutation
      del_q = deletions.dup
      # Initialize start values
      global_effective_offset = 0
      latest_del_start_pos = 0
      latest_del_length = 0
      # Create copy of self with adjusted positions
      AbsoluteSuspendedTokens.new(
        map { |tkn|
          # Clone token before mutation
          token = tkn.dup
          # Apply all salient deletions, accumulate effective offset.
          while(
            # Deletions queue is not empty
            del_q.any? &&
            # First deletion's position is before token position.
            del_q.first[0] < token.position
          ) do
            # Take deletion from queue
            del = del_q.shift
            # Remember latest deletion attrs (to handle multiple tokens
            # inside a single deletion)
            latest_del_length = del[1] - del[0]
            latest_del_start_pos = del[0]
            # Adjust globally effective offset
            global_effective_offset -= latest_del_length
          end
          # If a token falls inside a deletion, we don't apply the
          # full global_effective_offset, but just the start position
          # difference between token and deletion.
          token_effective_offset = if(
            token.position >= latest_del_start_pos &&
            token.position < (latest_del_start_pos + latest_del_length)
          )
            # Deletion overlaps current token, apply reduced offset
            latest_del_start_pos - token.position
          else
            # Token is outside of latest deletion, apply full offset
            global_effective_offset
          end
          # Adjust current token's position by token's effective_offset
          token.position += token_effective_offset
          token
        }
      )
    end

    # Returns copy of self, with token positions adjusted for insertions.
    #  * Applies all insertions that start before a token's position.
    #  * Accumulates the offset from prior insertions and applies it to
    #    all later tokens.
    #  * Unlike #adjust_for_deletions, does not need to handle situations
    #    where tokens fall between the start and end of an insertions
    #    (overlapping insertions). For insertions, we just apply the entire
    #    insertion before the token.
    #  * Keeps track of adjusted_token_position because of the way start and
    #    end positions for insertions are tracked.
    #  * Iterates over insertions and tokens in parallel for improved
    #    performance.
    # @param insertions [Array<Array>] as array of start/end pairs: [[0,3], [8,12], ...]
    # @param affinity [Symbol, optional] one of :left, :right, or reasonable default if nil.
    # @return [AbsoluteSuspendedTokens] a copy of self, adjusted for insertions
    def adjust_for_insertions(insertions, affinity = nil)
      assert_ordered_list_of_start_end_pairs(insertions)
      unless [:left, :right, nil].include?(affinity)
        raise "Unrecognized affinity value #{ affinity.inspect }"
      end

      # Default affinity to :right
      affinity ||= :right
      # Determine comp operator depending on affinity
      position_comparison_operator = (:left == affinity ? :< : :<=)
      # Clone insertions queue before mutation
      ins_q = insertions.dup
      # Initialize start values
      adjusted_token_position = nil
      effective_offset = 0
      token_effective_offset = 0

      # Create copy of self with adjusted positions
      AbsoluteSuspendedTokens.new(
        map { |tkn|
          # Clone token before mutation
          token = tkn.dup
          # Use this token's adjusted position so that
          # we can include insertions that would have fallen
          # after the token's original position (prior to adjustment).
          adjusted_token_position = token.position + effective_offset
          # Apply all salient insertions, accumulate effective offset.
          while(
            # Insertions queue is not empty
            ins_q.any? &&
            # First insertion's position is before (or at, depending
            # on affinity) adjusted token position.
            #     insertion_position <|<= adjusted_token_position
            ins_q.first[0].send(
              position_comparison_operator,
              adjusted_token_position
            )
          ) do
            # Take insertion from queue
            ins = ins_q.shift
            length_of_insertion = ins[1] - ins[0]
            # Adjust effective offset
            effective_offset += length_of_insertion
            # Update adjusted_token_position before comparison
            # with next insertion.
            adjusted_token_position = token.position + effective_offset
          end
          # Adjust current token's position
          token.position = adjusted_token_position
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
      each_cons(2) { |a,b|
        if a.position > b.position
          raise(
            TokensNotAscendingError,
            "Suspended Token positions must be monotonically ascending. #{ [a,b].inspect }"
          )
        end
      }
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
    # @param diff_list [Array<Array>] Array of tuples with start and end pos:
    #   [[0,3], [8,12], ...]
    def assert_ordered_list_of_start_end_pairs(diff_list)
      if diff_list.any? { |a| a.length != 2 }
        raise(StartEndPairsTypeError, "Array of start/end pairs expected")
      end
      diff_list.flatten.each_cons(2) { |(a,b)|
        if a > b
          raise(StartEndPairsNotAscendingError, "Array of start/end pairs is not ordered")
        end
      }
    end

  end
end
