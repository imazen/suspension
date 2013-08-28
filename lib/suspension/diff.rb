module Suspension
    module Diff
        # Expects nested array in form [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
        # See https://code.google.com/p/google-diff-match-patch/wiki/API
        # returns [removals], [additions] in absolute coordinates -> [[10,22]], [[10,23]]
        def self.split_diff_match_patch (diff_match_patch_list)
          remove = []
          remove_start = 0
          add = []
          add_start = 0
          for segment in diff_match_patch_list
            diff_length = segment[1].length 
            if segment[0] == -1
                remove << [remove_start, remove_start + diff_length]
                remove_start += diff_length
            elsif segment[0] == 1
                add << [add_start, add_start + diff_length]
                add_start += diff_length
            else 
                remove_start += diff_length 
                add_start += diff_length 
            end 
          end
          return remove, add
        end 
    end 

    class AbsoluteSuspendedTokens
        def with_deletions deletions
            AbsoluteSuspendedTokens.new self.map do |token| 
                #Accumulate all deletions prior to (or overlapping) the token
                token.position -= deletions.inject(0) do |total, del|
                    if del[0] < token.position
                        total + Math.min(token.position - del[0], del[1] - del[0]) 
                    else
                        total
                end 
            end 
        end

        def with_additions additions, affinity = :left
            raise "Unrecognized affinity value #{affinity.inspect}" unless [:left, :right].include? affinity

            AbsoluteSuspendedTokens.new self.map do |token| 
                #Accumulate all additions prior to (or overlapping) the token
                token.position += additions.inject(0) do |total, add|
                    if (affinity == :left && add[0] < token.position) ||
                        (affinity == :right && add[0] <= token.position)
                        total + add[1] - add[0]
                    else
                        total 
                end 
            end 
        end 
    end 
end
