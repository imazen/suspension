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
      token_start = 0
      @filtered_text = ""
      s = StringScanner.new(@original_doc)
      while !s.eos? do
        match_found = false
        active_tokens.each { |token|
          if(
            (
              !token.must_be_start_of_line ||      # doesn't need to be at beginning of line or
              s.beginning_of_line? ||              # is at beginning of line or
              (s.matched && "\n" == s.matched[-1]) # is preceded by `\n`, so effectively it's at beginning of line. (required for BLOCK_START whith preceding blank line)
            ) && (
              contents = s.scan(token.regex)       # matches token
            )
          )
            match_found = true
            if token.is_plaintext
              @filtered_text << contents
              token_start += contents.length
            else
              @suspended_tokens << SuspendedToken.new(token_start, token.name, contents)
              break # OPTIMIZE: investigate if moving break after this if statement makes things faster. Shouldn't we break on plaintext matches, too?
            end
          end
        }
        if !match_found
          ch = s.getch # Is a multi-byte character counted as length=1?
          # The fastest way of building a string in Ruby is to use the :<<
          # operator. (compared to String#+ and StringIO#<<)
          # See here for benchmarks:
          # * http://blog.codahale.com/2006/04/18/ever-wonder-which-is-the-fastest-way-to-concatenate-strings-in-ruby/
          # * http://stackoverflow.com/a/13276313/130830
          @filtered_text << ch
          token_start += ch.length
        end
      end
      self
    end

  end
end
