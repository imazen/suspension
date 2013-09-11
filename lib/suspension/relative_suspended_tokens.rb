module Suspension
  class RelativeSuspendedTokens < Array

    # Instantiates instance of self from serialized_tokens
    # @param[String] serialized_tokens a string representation of serialized tokens
    # @return[RelativeSuspendedTokens] an instance of self
    def self.deserialize(serialized_tokens)
      a = RelativeSuspendedTokens.new
      CSV.parse(serialized_tokens, { :col_sep => "\t", :row_sep => "\n" }) do |row|
        a << SuspendedToken.new(Integer(row[0]), row[1].to_sym, row[2])
      end
      a.validate
      a
    end

    # Serializes to tab-delimited format, using offsets instead of absolute
    # positions (makes diff better)
    # @return[String] serialized representation of self as tab-delimited string.
    def serialize
      CSV.generate({ :col_sep => "\t", :row_sep => "\n" }) do |csv|
        each do |token|
          csv << [token.position, token.name, token.contents]
        end
      end
    end

    # Converts self to a list of absolute suspended tokens.
    # @return[AbsoluteSuspendedTokens]
    def to_absolute
      last_position = 0
      AbsoluteSuspendedTokens.new(
        map { |rel_suspended_token|
          abs_suspended_token = rel_suspended_token.dup
          abs_suspended_token.position += last_position
          last_position += rel_suspended_token.position
          abs_suspended_token
        }
      )
    end

    # Validates self, raises exceptions as needed
    # @return[RelativeSuspendedTokens] self
    def validate
      if self.any? { |e| !e.is_a?(SuspendedToken) }
        raise "All members must be of type SuspendedTokens #{ entries.inspect }"
      end
      if self.any? { |i| i.position < 0 }
        raise "Negative offsets not permitted #{ entries.inspect }"
      end
      self
    end

  end
end
