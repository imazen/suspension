module Suspension
  class AbsoluteSuspendedTokens < Array

    def with_deletions(deletions)
      if(
        deletions.any? { |a| a.length != 2} || \
        deletions.flatten.reduce(0) { |result, e| e >= result ? e : false } === false
      )
        raise "Array of ordered begin/end pairs expected"
      end
      AbsoluteSuspendedTokens.new(
        self.map { |token|
          token = token.dup
          # Accumulate all deletions prior to (or overlapping) the token
          token.position -= deletions.reduce(0) do |total, del|
            if del[0] < token.position
              total + [token.position - del[0], del[1] - del[0]].min
            else
              total
            end
          end
          token
        }
      )
    end

    def with_insertions(insertions, affinity = :left)
      unless [:left, :right].include?(affinity)
        raise "Unrecognized affinity value #{ affinity.inspect }"
      end
      if(
        insertions.any? { |a| a.length != 2 } || \
        insertions.flatten.reduce(0){ |result, e| e >= result ? e : false } === false
      )
        raise "Array of ordered begin/end pairs expected"
      end
      AbsoluteSuspendedTokens.new(
        self.map { |token|
          token = token.dup
          # Accumulate all insertions prior to (or overlapping) the token
          token.position += insertions.reduce(0) { |total, ins|
            if(
              (affinity == :left && ins[0] < token.position) || \
              (affinity == :right && ins[0] <= token.position)
            )
              total + ins[1] - ins[0]
            else
              total
            end
          }
          token
        }
      )
    end

    def to_relative
      last_position = 0
      RelativeSuspendedTokens.new(
        self.map { |i|
          n = i.dup
          n.position = i.position - last_position
          last_position = i.position
          n
        }
      ).validate
    end

    def validate
      if self.any? { |i| !i.is_a?(SuspendedToken) }
        raise "All members must be of type SuspendedTokens. #{self.inspect}"
      end
      if self.reduce(0){ |result, e| e.position >= result ? e.position : false } === false
        raise  "Suspended Tokens must be in ascending order. #{elem.position} found after #{result}"
      end
      self
    end

    #Performs a stable sort
    def stable_sort
      n = 0
      AbsoluteSuspendedTokens.new(sort_by { |x| n+= 1; [x.position, n] })
    end

  end
end
