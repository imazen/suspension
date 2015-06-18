module Suspension
  # Compares strings and returns diffs
  class StringComparer

    # Compares string_1 with string_2 using diff_match_patch.
    # @param[String] string_1
    # @param[String] string_2
    # @return[Array] An array of diffs like so:
    # [[1, 'added', 'line 42', 'text_before text_after'], [-1, 'removed ', 'line 43', 'text_before removed text_after']]
    # All information is relative to string_1. 1 means a string was added, -1 it was deleted.
    def self.compare(string_1, string_2)
      if string_1 == string_2
        return []
      else
        diffs = Suspension::DiffAlgorithm.new.call(string_1, string_2)
        # Add context information to diffs
        begin
          deltas = []
          char_num = 0
          line_num = 1
          excerpt_window = 20
          idx = -1
          diffs.each { |diff|
            idx += 1 # can't use each_with_index since I need idx in rescue
            excerpt_start = [(char_num - excerpt_window), 0].max
            excerpt_end = [(char_num + diff.last.length + excerpt_window), string_1.length].min
            excerpt = case diff.first
            when -1
              # use string_1 as context for deletions
              string_1[excerpt_start..excerpt_end]
            when 1
              # use string_2 as context for additions
              string_2[excerpt_start..excerpt_end]
            when 0
              nil
            else
              raise "Handle this: #{ diff.inspect }"
            end
            r = [
              diff.first, # type of modification
              diff.last, # diff string
              "line #{ line_num }",
              excerpt
            ]
            if [0,-1].include?(diff.first)
              # only count chars and newlines in identical or deletions since all info
              # refers to string_1
              char_num += diff.last.length
              line_num += diff.last.count("\n")
            end
            deltas << r
          }
        rescue ArgumentError => e
          if e.message.index('invalid byte sequence')
            # Handles invalid UTF-8 byte sequences in diff
            # This is caused by two different multibyte characters at the
            # same position where the first bytes are identical, and a
            # subsequent one is different. DMP splits that multibyte char into
            # separate bytes and thus creates an invalid UTF8 character.
            # Here we re-combine the bytes into a valid UTF8 string, giving
            # up some diff precision.

            # We currently handle only one scenario where we have common prefix
            # and different suffixes.
            # Strategy: Remove common prefix, prepend it to the two different
            # suffixes and use the combined strings as diffs.
            common_prefix = diffs[idx].last
            diffs[idx+1][1].prepend(common_prefix) # prepend to +1
            diffs[idx+2][1].prepend(common_prefix) # prepend to +2
            diffs.delete_at(idx) # delete the common prefix
            retry
          else
            valid_excerpt, valid_string = [excerpt, diff.last].map { |e|
              e.to_s.force_encoding('UTF-8') \
                    .encode('UTF-16', :invalid => :replace, :replace => '[invalid UTF-8 byte]') \
                    .encode('UTF-8')
            }
            $stderr.puts "Error details:"
            $stderr.puts " - line: #{ line_num }"
            $stderr.puts " - diff: #{ valid_string.inspect }"
            $stderr.puts " - excerpt: #{ excerpt.inspect }"
            raise e
          end
        end
        deltas = deltas.find_all { |e| 0 != e.first }
      end
    end

  end
end
