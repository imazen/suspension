module Suspension
  class Suspender

    attr_accessor :original_text, :token_library
    attr_reader :filtered_text, :matched_tokens

    def initialize(original_text, token_library)
      @original_text = original_text
      @token_library = token_library
    end

    def suspend(token_names = nil)
      token_names = token_names || token_library.map { |t| t.name }
      active_tokens = token_library.select { |t|
      	token_names.map(&:to_sym).include?(t.name.to_sym)
      }

      @matched_tokens = AbsoluteSuspendedTokens.new
      token_start = 0
      @filtered_text = ""

      s = StringScanner.new(@original_text)
      while !s.eos? do
        no_match = true
        active_tokens.each { |token|
          if contents = s.scan(token.regex)
            if token.is_plaintext
              @filtered_text += contents
              token_start += contents.length
            else
              matched_tokens << SuspendedToken.new(token_start, token.name, contents)
              no_match = false
              break
            end
          end
        }
        if no_match
          ch = s.getch #Is a multi-byte character counted as length=1?
          @filtered_text += ch
          token_start += ch.length
        end
      end
      self
    end

  end
end
