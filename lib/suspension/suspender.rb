module Suspension
  class Suspender

    attr_accessor :original_doc, :token_library
    attr_reader :filtered_text # the original_doc minus suspended tokens
    attr_reader :suspended_tokens # any tokens suspended from original_doc

    # @param[String] original_doc document that contains tokens to be suspended
    # @param[Array<Token>] token_library an array of tokens to suspend.
    #     Suspension::REPOSITEXT_TOKENS is an example.
    def initialize(original_doc, token_library)
      @original_doc = original_doc
      @token_library = token_library
    end

    # Suspends tokens from original_doc, computes
    # * filtered_text - the original_doc minus suspended tokens
    # * suspended_tokens - a list of absolute suspended tokens
    # @param[Array<Symbol>, optional] token_names an array of symbolized token
    #                                 names, defaults to names from @token_library
    # @return[Suspender] self
    def suspend(token_names = nil)
      token_names = token_names || token_library.map { |t| t.name }
      active_tokens = token_library.select { |t|
      	token_names.map(&:to_sym).include?(t.name.to_sym)
      }
      @suspended_tokens = AbsoluteSuspendedTokens.new
      @filtered_text = ""
      token_start = 0
      effective_bol = nil
      previously_consumed_token_was_at_bol = nil
      s = StringScanner.new(@original_doc)
      while !s.eos? do
        # puts
        # puts '-' * 40
        # puts "New ss pos: #{ (s.post_match || s.rest).inspect }"
        match_found = false
        # Compute effective_bol flag. The current position is considered
        # beginning of line if any of the following ist true:
        #  * Current pos is at beginning of line.
        #  * Previous token was at bol and was removed.
        #  * Next char is `\n`, so effectively it's at beginning of line. This
        #    is required for block level tokens that are preceded by only one,
        #    not two `\n`, but should still consume the leading `\n`.
        #    See repositext_tokens.rb BLOCK_START for more details.
        effective_bol = (
          s.beginning_of_line? ||
          previously_consumed_token_was_at_bol ||
          "\n" == s.peek(1)
        )
        active_tokens.each { |token|
          # puts "- trying token #{ token.name }"
          # puts "  #{ !token.must_be_start_of_line } || #{ s.beginning_of_line? } || #{ "\n" == s.peek(1) }"
          previously_consumed_token_was_at_bol = false
          if(
            !token.must_be_start_of_line || effective_bol) &&
            (contents = s.scan(token.regex)
          )
            # Token doesn't need to be at beginning of line or
            # current pos is effectively at beginning of line
            # and rest matches token's regex
            match_found = true
            if token.is_plaintext
              # puts '  - found plaintext '
              # puts "    #{ contents.inspect }"
              @filtered_text << contents
              token_start += contents.length
            else
              # puts '  - found token '
              # puts "    start: #{ token_start }, name: #{ token.name }, contents: #{ contents.inspect }"
              @suspended_tokens << SuspendedToken.new(token_start, token.name, contents)
              previously_consumed_token_was_at_bol = effective_bol
              break # OPTIMIZE: investigate if moving break after this if statement makes things faster. Shouldn't we break on plaintext matches, too?
            end
          end
        }
        if !match_found
          ch = s.getch # Is a multi-byte character counted as length=1?
          # puts '- no match, getch '
          # puts "  #{ ch.inspect }"
          @filtered_text << ch
          token_start += ch.length
        end
      end
      self
    end

  end
end
