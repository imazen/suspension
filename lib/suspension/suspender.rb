module Suspension
    

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