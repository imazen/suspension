
require 'strscan'
require 'csv'

module Suspension
  class Token < Struct.new(:name, :regex)
  end 

  class SuspendedToken < Struct.new(:position, :name, :contents)
  end

  class RelativeSuspendedTokens < Array

    # Serialized to tab-delimited format, using offsets instead of absolute positions (makes diff better)
    def serialize
      CSV.generate({:col_sep => '\t', :row_sep => '\n'}) do |csv|
        for token in self
          csv << [token.position, token.name, token.contents]
        end
      end 
    end

    def self.deserialize(text)
      a = RelativeSuspendedTokens.new
      CSV.parse text, {:col_sep => '\t', :row_sep => '\n'}  do |row|
        a << SuspendedToken.new(row[0], row[1].to_sym, row[2])
      end
      a.validate
      a
    end

    def to_absolute
      last_position = 0
      AbsoluteSuspendedTokens.new(self.map do |i|
        n = i.dup
        n.position += last_position
        last_position += i.position
      end)
    end 

    def validate
      raise "Negative offsets not permitted" if self.any? { |i| i.position < 0}
      self
    end

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


    def apply_deletions deleted
      token_index = 0
      last_token = 0 # Absolute position of last token

      for deletion in deleted
        current_offset = 0
        while token_index < length
          t = self[token_index]

          t.position -= current_offset

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

  class AbsoluteSuspendedTokens < Array

    def to_relative
      last_position = 0
      RelativeSuspendedTokens.new( self.map do |i|
        n = i.dup
        n.position = i.position - last_position
        last_position = i.position
      end).validate
    end 

  end


  class Unsuspender < Struct.new(:filtered_text, :suspended_tokens)

    attr_reader :output_text

    # Restores the suspended tokens back into their original locations in filtered_text
    # If an array of token_names is specified, only tokens with matching names will be restored - others will be discarded
    def restore (token_names)
      #Convert token names to symbols
      token_names = token_names.map(&:to_sym) if token_names
      #Ensure suspended tokens are in absolute form so they can safely be filtered
      suspended_tokens = suspended_tokens.to_absolute if suspended_tokens.is_a? RelativeSuspendedTokens
      #Filter suspended tokens
      token_subset = token_names.nil? ? suspended_tokens : suspended_tokens.select {|t| token_names.include? t.name }


      @output_text = ""
      last_token = 0
      last_position_validate = nil
      for token in token_subset
        @output_text += @filtered_text[last_token..token.position]
        last_token = token.position - last_token
        @output_text += token.contents
        raise "Suspended Tokens Out Of Order at #{token.position}" if last_position_validate && last_position_validate > token.position
        last_position_validate = token.position
      end
      @output_text += filtered_text[last_token..-1]
      @output_text
    end

  end 

  class Suspender

    attr_accessor :original_text, :token_library
    attr_reader :filtered_text, :matched_tokens

    def initialize(originalText, tokenLibrary)
      @original_text = originalText
      @token_library = tokenLibrary
    end

    def suspend (token_names)
      token_names = token_names || token_library.tokens.map { |t| t.name }
      active_tokens = token_library.tokens.select { |t| token_names.map(&:to_sym).include? token_names.name.to_sym }
      active_tokens << Token.new(:remnants, /./m)

      @matched_tokens = AbsoluteSuspendedTokens.new
      matched_tokens_length = 0
      @filtered_text = ""

      s = StringScanner.new(@original_text)
      while (!s.eos?)
          no_match = true
          for token in active_tokens
            if contents = s.scan(token.regex)
              if token.name == :remnants
                filtered_text += contents
                no_match = false
                break
              end
              matched_tokens << SuspendedToken.new(s.position - matched_tokens_length, token.name, contents)
              matched_tokens_length += contents.length
              no_match = false
              break
            end 
          end 
          raise "Failed to match #{s.rest[0..100]}" if no_match
      end 

    end

  end



end 
