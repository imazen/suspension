# infrastructure
require 'rubygems'
require 'minitest/autorun'

# code under test
require 'suspension'

module Suspension
  class AbsoluteSuspendedTokens

    def self.from_flat flat
      self.new flat.each_slice(2).map { |pair|
        SuspendedToken.new(pair[0], :mark, pair[1])
      }
    end

    def to_flat
      self.map{ |t| [t.position, t.contents] }.flatten
    end

  end

  class RelativeSuspendedTokens

    def self.from_flat(flat)
      self.new flat.each_slice(2).map { |pair|
        SuspendedToken.new(pair[0], :mark, pair[1])
      }
    end

    def to_flat
      self.map{ |t| [t.position, t.contents] }.flatten
    end

  end
end
