
module Suspension
  class Token < Struct.new(:name, :regex)
  end 

  class SuspendedToken < Struct.new(:position, :name, :contents)
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
  end 
end 