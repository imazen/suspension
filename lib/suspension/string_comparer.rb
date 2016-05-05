module Suspension
  # Compares strings and returns diffs
  class StringComparer

    # Compares string_1 with string_2 using diff_match_patch.
    # @param string_1 [String]
    # @param string_2 [String]
    # @param add_context_info [Boolean, optional] if true will add location and excerpt
    # @param different_only [Boolean, optional] if true will show -1 and 1 segments only
    # @param options [Hash, optional] with symbolized keys
    # @return[Array] An array of diffs like so:
    # [[1, 'added', 'line 42', 'text_before text_after'], [-1, 'removed ', 'line 43', 'text_before removed text_after']]
    # All information is relative to string_1. 1 means a string was added, -1 it was deleted.
    def self.compare(string_1, string_2, add_context_info=true, different_only=true, options={})
      options = {
        excerpt_window: 20, # how much context do we show before and after
      }.merge(options)
      if string_1 == string_2
        return []
      else
        diffs = Suspension::DiffAlgorithm.new.call(string_1, string_2)
        # Add context information to diffs
        deltas = []
        # We need to keep separate char counters for string_1 and string_2 so
        # that we can pull the excerpt for either of them.
        char_pos_1 = 0 # character counter on string_1
        char_pos_2 = 0 # character counter on string_2
        line_num_1 = 1 # line counter on string_1. We don't need one for string_2
        excerpt_window = options[:excerpt_window]
        # I have to do a manual loop since we're relying on idx for exception
        # rescue retries on invalid utf8 byte sequences
        idx = 0
        diffs.length.times {
          begin
            diff = diffs[idx]
            if add_context_info
              # Add location and excerpt
              excerpt = case diff.first
              when -1
                # use string_1 as context for deletions
                excerpt_start = [(char_pos_1 - excerpt_window), 0].max
                excerpt_end = [(char_pos_1 + excerpt_window), string_1.length].min - 1
                line_num_1 += diff.last.count("\n") # do first as it can raise exception
                char_pos_1 += diff.last.length
                string_1[excerpt_start..excerpt_end]
              when 1
                # use string_2 as context for additions
                excerpt_start = [(char_pos_2 - excerpt_window), 0].max
                excerpt_end = [(char_pos_2 + excerpt_window), string_2.length].min - 1
                char_pos_2 += diff.last.length
                string_2[excerpt_start..excerpt_end]
              when 0
                line_num_1 += diff.last.count("\n") # do first as it can raise exception
                char_pos_1 += diff.last.length
                char_pos_2 += diff.last.length
                nil
              else
                raise "Handle this: #{ diff.inspect }"
              end
              r = [
                diff.first, # type of modification
                diff.last, # diff string
                "line #{ line_num_1 }",
                excerpt
              ]
            else
              # Use diffs as returned by DMP
              diff.last.match(/./) # Trigger exception for invalid byte sequence in UTF-8
              r = diff
            end
            deltas << r
            # Increment at the end of rescue block so that retries are idempotent
            idx += 1
          rescue ArgumentError => e
            if e.message.index('invalid byte sequence')
              # Handles invalid UTF-8 byte sequences in diff
              # This is caused by two different multibyte characters at the
              # same position where the first bytes are identical, and a
              # subsequent one is different. DMP splits that multibyte char into
              # separate bytes and thus creates an invalid UTF8 byte sequence:
              #
              # Example: "word2—word3" and "word2…word3"
              #
              # [
              #   [0, "word2\xE2\x80"],
              #   [-1, "\x94word3"],
              #   [1, "\xA6word3"]
              # ]
              #
              # Here we re-combine the bytes into a valid UTF8 string.
              #
              # Strategy: Remove trailing invalid bytes from common prefix, and
              # prepend them to the two different suffixes and use the combined
              # strings as diffs.
              #
              invalid_diff = diffs[idx].last
              last_valid_byte_pos = -1
              until(
                (lvb = invalid_diff[last_valid_byte_pos]).nil? ||
                lvb.valid_encoding?
              )
                last_valid_byte_pos -= 1
                if last_valid_byte_pos < -5
                  # Stop after looking back for 5 bytes
                  raise "Handle this: #{ invalid_diff.inspect }"
                end
              end
              valid_prefix = invalid_diff[0..last_valid_byte_pos]
              invalid_suffix = invalid_diff[(last_valid_byte_pos + 1)..-1]
              # Prepend following diffs with invalid_suffix if:
              # * They exist
              # * Are invalid
              # * Don't have the bytes applied already. There are situations
              #   where the algorithm may apply twice. See test case:
              #       "word1 word2—word2…word3 word4 word5"
              #       "word1 word2…word3 word4"
              if(
                diffs[idx+1] &&
                !diffs[idx+1][1].valid_encoding? &&
                diffs[idx+1][1].byteslice(0,invalid_suffix.bytesize) != invalid_suffix
              )
                # Prepend invalid_suffix to idx+1
                diffs[idx+1][1].prepend(invalid_suffix)
              end
              if(
                diffs[idx+2] &&
                !diffs[idx+2][1].valid_encoding? &&
                diffs[idx+2][1].byteslice(0,invalid_suffix.bytesize) != invalid_suffix
              )
                # Prepend invalid_suffix to idx+2
                diffs[idx+2][1].prepend(invalid_suffix)
              end
              # Replace invalid_diff with valid_prefix
              diffs[idx] = [diffs[idx].first, valid_prefix]
              retry
            else
              valid_excerpt, valid_string = [excerpt, diff.last].map { |e|
                e.to_s.force_encoding('UTF-8') \
                      .encode('UTF-16', :invalid => :replace, :replace => '[invalid UTF-8 byte]') \
                      .encode('UTF-8')
              }
              $stderr.puts "Error details:"
              $stderr.puts " - line: #{ line_num_1 }"
              $stderr.puts " - diff: #{ valid_string.inspect }"
              $stderr.puts " - excerpt: #{ excerpt.inspect }"
              raise e
            end
          end
        }

        if different_only
          deltas.find_all { |e| 0 != e.first }
        else
          deltas
        end
      end
    end

  end
end
