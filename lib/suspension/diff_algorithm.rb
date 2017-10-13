module Suspension
  class DiffAlgorithm

    # The ruby diff_match_patch gem returns symbols instead of integers for the
    # segment type. This hash converts the symbols to the corresponding integers
    # so that we can use the standard DMP API higher up the call stack.
    # It returns nil for unexpected keys.
    SYM_TO_INT_MAP = {
      :delete => -1,
      :equal => 0,
      :insert => 1,
      -1 => -1,
      0 => 0,
      1 => 1
    }

    # Generates a diff to transform a to b
    # @param[String] a the 'from' text
    # @param[String] b the 'to' text
    # @return[Array<Array>] diff_match_patch_list an array of tuples where the
    #     first item is the segment type (-1 for deletion, 0 for equality, 1 for
    #     insertion) and the second item is the segment content as string:
    #     Example: [[-1, "a"], [0, "ab"], [-1, "b"], [1, "x"], [0, "ccnn"], [1, "e"]]
    def call(a,b)
      # convert dmp output from
      # [[:delete, "a"], [:equal, "ab"], [:delete, "b"], [:insert, "x"], [:equal, "ccnn"], [:insert, "e"]]
      # to
      # [[-1, "a"], [0, "ab"], [-1, "b"], [1, "x"], [0, "ccnn"], [1, "e"]]
      dmp = DiffMatchPatch.new

      dmp.diff_timeout = 0
      dmp.diff_edit_cost = 10 if dmp.respond_to? :diff_edit_cost
      dmp.diff_editCost = 10 if dmp.respond_to? :diff_editCost

      diffs = dmp.diff_main(a,b,false).map { |e|
        # NOTE on utf8 awareness: The diff_match_patch_native library is not
        # UTF8 aware and does not tag strings as UTF-8, so Ruby considers them
        # to be ASCII-8BIT/BINARY encoded.
        # Turns out that they are actually UTF-8 encoded, just improperly tagged.
        # So for Suspension to work, we can use force_encoding since we know
        # that the input strings were encoded in UTF-8.
        utf8_encoded_string = if(Encoding::ASCII_8BIT == e[1].encoding)
          # This string came from diff_match_patch_native, force encode to UTF-8
          e[1].force_encoding("UTF-8")
        else
          # This string came from diff_match_patch (Ruby), leave as is
          e[1]
        end
        [SYM_TO_INT_MAP[e[0]], utf8_encoded_string]
      }

      # Since dmp is not utf8 aware, it can produce invalid UTF-8 byte sequences
      # in the resulting diffs. This can be caused, e.g., by two
      # different multibyte characters at the same position where the first
      # bytes are identical, and a subsequent one is different. Dmp splits that
      # multibyte char into separate diff units and thus creates invalid UTF8
      # byte sequences.
      #
      # Example: "a—b" and "a…b"
      #
      # [
      #   [0, "a\xE2\x80"],
      #   [-1, "\x94b"],
      #   [1, "\xA6b"]
      # ]
      #
      # This is normally not a problem since combining the diff units will
      # result in valid utf8 byte sequences. However, in suspension we need to
      # measure diff string lengths for token suspension and unsuspension, so
      # the broken utf8 byte sequences get in the way and we need to fix them.
      # We fix these invalid diffs by moving separated byte sequences back
      # together.
      invalid_diff_clusters = diffs.each_with_index.chunk { |diff,idx|
        if diff[1].valid_encoding?
          nil
        else
          :cluster
        end
      }

      if invalid_diff_clusters.any?
        fix_invalid_diffs!(diffs, invalid_diff_clusters)
      end

      diffs
    end

  protected

    DIFF_STR_IDX = 1
    DIFF_TYPE_IDX = 0

    # Fixes invalid diffs in place by moving partial utf8 char bytes together.
    # @param diffs [Array<Array>] The global diffs
    # @param invalid_diff_clusters [Array<Array<Array>>]
    # Modifies diffs in place.
    def fix_invalid_diffs!(diffs, invalid_diff_clusters)
      # NOTES: The diffs in each cluster must have consecutive indexes
      # Ideas for resolving:
      #  * invalid bytes will always be at the margins (start or end) of the string.
      invalid_diff_clusters.each { |(cluster_marker, clustered_diffs)|
        cluster_signature = clustered_diffs.map { |diff, idx| diff[DIFF_TYPE_IDX] }
        diff_idxs = clustered_diffs.map { |diff, idx| idx }
        case cluster_signature
        when [-1, 1, 0]
          # Diff with same end byte
          # Move leading invalid bytes of last diff to end of two first diffs
          bs2mv, b_count = get_leading_invalid_bytes(diffs[diff_idxs[2]][DIFF_STR_IDX])
          diffs[diff_idxs[0]][DIFF_STR_IDX] << bs2mv
          diffs[diff_idxs[1]][DIFF_STR_IDX] << bs2mv
          diffs[diff_idxs[2]][DIFF_STR_IDX] = diffs[diff_idxs[2]][DIFF_STR_IDX].byteslice(b_count..-1)
        when [0, -1, 1]
          # Diff with same start byte.
          # Move trailing invalid bytes of first diff to beginning of two last diffs
          bs2mv, b_count = get_trailing_invalid_bytes(diffs[diff_idxs[0]][DIFF_STR_IDX])
          diffs[diff_idxs[0]][DIFF_STR_IDX] = diffs[diff_idxs[0]][DIFF_STR_IDX].byteslice(0...(-b_count))
          diffs[diff_idxs[1]][DIFF_STR_IDX].prepend(bs2mv)
          diffs[diff_idxs[2]][DIFF_STR_IDX].prepend(bs2mv)
        when [0, -1, 0],
             [0, 1, 0]
          # Deletion or insertion with same end byte
          # Start from the end so that we get a valid byte sequence in the middle one
          # Move leading invalid bytes of third diff to end of second diff
          bs2mv, b_count = get_leading_invalid_bytes(diffs[diff_idxs[2]][DIFF_STR_IDX])
          diffs[diff_idxs[1]][DIFF_STR_IDX] << bs2mv
          diffs[diff_idxs[2]][DIFF_STR_IDX] = diffs[diff_idxs[2]][DIFF_STR_IDX].byteslice(b_count..-1)
          # Move leading invalid bytes of second diff to end of first diff
          bs2mv, b_count = get_leading_invalid_bytes(diffs[diff_idxs[1]][DIFF_STR_IDX])
          diffs[diff_idxs[0]][DIFF_STR_IDX] << bs2mv
          diffs[diff_idxs[1]][DIFF_STR_IDX] = diffs[diff_idxs[1]][DIFF_STR_IDX].byteslice(b_count..-1)
        when [-1, 1, 0, -1, 1]
          # Diff with same middle byte
          # Join center with two surrounding deletions into one deletion
          diffs[diff_idxs[0]][DIFF_STR_IDX] << diffs[diff_idxs[2]][DIFF_STR_IDX]
          diffs[diff_idxs[0]][DIFF_STR_IDX] << diffs[diff_idxs[3]][DIFF_STR_IDX]
          # Join center with two surrounding insertions into one insertion
          diffs[diff_idxs[1]][DIFF_STR_IDX] << diffs[diff_idxs[2]][DIFF_STR_IDX]
          diffs[diff_idxs[1]][DIFF_STR_IDX] << diffs[diff_idxs[4]][DIFF_STR_IDX]
          # Set diffs to be deleted to nil. Don't delete them here. Otherwise
          # all diff indexes would become invalid.
          diffs[diff_idxs[2]] = nil
          diffs[diff_idxs[3]] = nil
          diffs[diff_idxs[4]] = nil
        when [0, -1, 1, 0]
          # Diff with same start and end bytes
          # Move trailing invalid bytes of first diff to beginning of second and third diffs
          bs2mv, b_count = get_trailing_invalid_bytes(diffs[diff_idxs[0]][DIFF_STR_IDX])
          diffs[diff_idxs[0]][DIFF_STR_IDX] = diffs[diff_idxs[0]][DIFF_STR_IDX].byteslice(0...(-b_count))
          diffs[diff_idxs[1]][DIFF_STR_IDX].prepend(bs2mv)
          diffs[diff_idxs[2]][DIFF_STR_IDX].prepend(bs2mv)
          # Move leading invalid bytes of fourth diff to beginning of second and third diffs
          bs2mv, b_count = get_leading_invalid_bytes(diffs[diff_idxs[3]][DIFF_STR_IDX])
          diffs[diff_idxs[1]][DIFF_STR_IDX] << bs2mv
          diffs[diff_idxs[2]][DIFF_STR_IDX] << bs2mv
          diffs[diff_idxs[3]][DIFF_STR_IDX] = diffs[diff_idxs[3]][DIFF_STR_IDX].byteslice(b_count..-1)
        else
          raise "Handle this: #{ clustered_diffs }.inspect"
        end
      }
      # Remove all diffs that were set to nil for deletion
      diffs.compact!
      true
    end

    # Returns the invalid leading bytes and their count as array
    # @param inv_str [String] the string with leading invalid bytes
    # @return [Array<String, Integer>] tuple of invalid bytes and their count
    def get_leading_invalid_bytes(inv_str)
      first_valid_byte_pos = 0
      until(
        (fvb = inv_str.byteslice(first_valid_byte_pos)).nil? ||
        # fvb.valid_encoding? ||
        start_of_utf8_char?(fvb)
      )
        first_valid_byte_pos += 1
        if first_valid_byte_pos > 5
          # Stop after looking at 5 bytes
          raise "Handle this: #{ inv_str.inspect }"
        end
      end
      byte_count = first_valid_byte_pos
      invalid_bytes = inv_str.byteslice(0, byte_count)
      [invalid_bytes, byte_count]
    end

    # Returns the invalid trailing bytes and their count as array
    # @param inv_str [String] the string with trailing invalid bytes
    # @return [Array<String, Integer>] tuple of invalid bytes and their count
    def get_trailing_invalid_bytes(inv_str)
      # When trying to find trailing invalid bytes, we need to detect the last
      # start byte of a valid utf8 char (or the beginning of the string).
      # There are two kinds of bytes in utf8:
      #   * Start bytes: Depend on number of bytes in char.
      #   * Continuation bytes: always start with `10xxxxxx`
      # We may encounter the following scenarios:
      #   * Start of partial utf8 char
      #     110xxxxx ... (only first byte of a two byte char)
      #     1110xxxx ... (only first byte of a three byte char)
      #     1110xxxx 10xxxxxx ... (only first two bytes of a three byte char)
      #     11110xxx ... (only first byte of a four byte char)
      #     11110xxx 10xxxxxx ... (only first two bytes of a four byte char)
      #     11110xxx 10xxxxxx 10xxxxxx ... (only first three bytes of a four byte char)
      #   * complete utf8 char (1-4 bytes) followed by start of partial utf8 char.
      #     0xxxxxxx <followed by any of the partial scenarios above> (single byte char followed by partial utf8 char)
      #   * end of partial previous utf8 char followed by start of partial next utf8 char.
      #     10xxxxxx <followed by any of the partial scenarios above> (last byte of multibyte char followed by partial utf8 char)
      # Strategy to detect start of trailing invalid bytes:
      #   * Start from end of string, going forward.
      #   * Go until we detect one of the following:
      #       * utf8 start byte
      #       * beginning of string
      last_pos = inv_str.bytesize - 1
      first_invalid_byte_pos = last_pos
      until(
        0 == first_invalid_byte_pos ||
        start_of_utf8_char?(inv_str.byteslice(first_invalid_byte_pos))
      )
        first_invalid_byte_pos -= 1
        if first_invalid_byte_pos < last_pos - 5
          # Stop after looking back for 5 bytes
          raise "Handle this: #{ inv_str.inspect }"
        end
      end
      byte_count = (last_pos - first_invalid_byte_pos) + 1
      invalid_bytes = inv_str.byteslice(first_invalid_byte_pos..last_pos)
      r = [invalid_bytes, byte_count]
    end

    START_BYTE_MASKS_AND_MATCHES = [
      [0b10000000, 0b00000000],
      [0b11100000, 0b11000000],
      [0b11110000, 0b11100000],
      [0b11111000, 0b11110000],
    ]

    # Returns true if a_byte is the start of a valid utf8 encoded char.
    # See https://en.wikipedia.org/wiki/UTF-8 for more info.
    # @param a_byte [String] single byte value
    def start_of_utf8_char?(a_byte)
      # A new character in utf8 starts with one of the following:
      # Number of bytes  First Byte
      # 1                0xxxxxxx
      # 2                110xxxxx
      # 3                1110xxxx
      # 4                11110xxx
      byte_val = a_byte.getbyte(0)
      START_BYTE_MASKS_AND_MATCHES.any? { |mask, match|
        byte_val & mask == match
      }
    end

  end
end
