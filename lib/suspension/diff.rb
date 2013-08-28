module Suspension
    module Diff
        # Expects nested array in form [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
        # See https://code.google.com/p/google-diff-match-patch/wiki/API
        # returns [removals], [additions] in absolute coordinates -> [[10,22]], [[10,23]]
        def self.dmp_to_add_delete (diff_match_patch_list)
          diff_start = 0 # Absolute position of current segment

          remove = []
          add = []
          for segment in diff_match_patch_list
            diff_length = segment[1].length 
            diff_end = diff_start + diff_length 

            remove << [diff_start,diff_end] if segment[0] == -1
            add << [diff_start,diff_end] if segment[0] == 1

            diff_start = diff_end 
          end
          return remove, add
        end 


    end 

    class 
    def apply_deletions deleted
      token_index = 0
      last_token = 0 # Absolute position of last token

      for deletion in deleted
        size = deletion[1] - deletion[0]
        leftover = size 
        while token_index < length
          t = self[token_index]

          t.position += leftover

          token_pos = last_token + t.position + current_offset

          next if token_pos < deletion[0] #this token isn't affected

          offset = Math.min(token_pos - deletion[0], deletion[1] - deletion[0])
          current_offset += offset
          t.position -= offset 

          token_index++
        end

      end
    end 


    def apply_add_delete deleted, added, affinity = :left



      end 
diff_start = 0 # Absolute position of current segment
      last_token = 0 # Absolute position of last token
      token_index = 0

      for segment in diff_match_patch_list
        diff_length = segment[1].length 
        diff_end = diff_start + diff_length 

        current_offset = 0

        ## Update relative positions of tokens
        while (token_index < length)
          t = self[token_index]

          token_pos = last_token + t.position - current_offset

          next if token_pos < diff_start #this token isn't affected

          if segment[0] == -1
            offset = -Math.min(token_pos - diff_start, diff_length)
            current_offset += offset
    end


    # Expects nested array in form [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    # See https://code.google.com/p/google-diff-match-patch/wiki/API
    # Default affinity is left (changes touching or overlapping the token may shift the token left)
    def apply_dmp_list diff_match_patch_list, affinity = :left
      diff_start = 0 # Absolute position of current segment
      last_token = 0 # Absolute position of last token
      token_index = 0

      for segment in diff_match_patch_list
        diff_length = segment[1].length 
        diff_end = diff_start + diff_length 

        # Skip equal and zero-length segments
        if segment[0] == 0 || diff_length == 0
          diff_start = diff_end 
          next
        end

        current_offset = 0

        ## Update relative positions of tokens
        while (token_index < length)
          t = self[token_index]

          token_pos = last_token + t.position - current_offset

          next if token_pos < diff_start #this token isn't affected

          if segment[0] == -1
            offset = -Math.min(token_pos - diff_start, diff_length)
            current_offset += offset
          elsif segment[0] == 1
            offset = affinity == :left ? 

          end 

          #We need to continue to the next segment, 
          break if token_pos > diff_end #this token 
          raise "Bypassed tokens" if token_pos < diff_start 

          case affinity
          when :left
            offset = last_diff - token_pos
            apply_segment = last_diff + top[1].length < token_pos
            token.position -= token_pos - (last_diff + top[1].length)
            = (affinity == :left ? (pos < token_pos) : (pos + diff.last[1].length <= token_pos)) && (top = diff.pop)
          when :right
            break unless last_diff + top[1].length <
          else
            raise "Unrecognized affinity value #{affinity.inspect}"
          end 

          t.position += offset

          token_index += 1 unless current_offset 
          last_token += t.position
        end 

        diff_start += diff_length * segment[0]
      end
    end

  end


end
