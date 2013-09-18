module Suspension
  class Suspender

    attr_accessor :original_text, :token_library
    attr_reader :filtered_text # the original_text minus suspended tokens
    attr_reader :suspended_tokens # any tokens suspended from original_text

    # @param[String] original_text the text that contains tokens to be suspended
    # @param[Array<Token>] token_library an array of tokens to suspend
    def initialize(original_text, token_library)
      @original_text = original_text
      @token_library = token_library
    end

    # Suspends tokens from original_text, computes
    # * filtered_text - the original_text minus suspended tokens
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

      s = StringScanner.new(@original_text)
      while !s.eos? do
        no_match = true
        active_tokens.each { |token|
          if (!token.must_be_start_of_line || s.beginning_of_line?) && (contents = s.scan(token.regex))
            if token.is_plaintext
              @filtered_text += contents
              token_start += contents.length
            else
              @suspended_tokens << SuspendedToken.new(token_start, token.name, contents)
              no_match = false
              break
            end
          end
        }
        if no_match
          ch = s.getch # Is a multi-byte character counted as length=1?
          @filtered_text += ch
          token_start += ch.length
        end
      end
      self
    end

  end
end
