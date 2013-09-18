# infrastructure
require 'rubygems'
require 'minitest/autorun'

# add lib dir to LOAD_PATH in case we run specs outside of Rake
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

# code under test
require 'suspension'

module Suspension

  class AbsoluteSuspendedTokens

    # Instantiates new instance of self from flat array of token tuples.
    # @param[Array<Integer, String>] flat array representation of
    #     AbsoluteSuspendedTokens, consists of tuples with absolute position and
    #     contents each.
    #     Example: [1,'a', 3,'bb']
    # @return[AbsoluteSuspendedTokens]
    def self.from_flat(flat)
      self.new(
        flat.each_slice(2).map { |pair|
          SuspendedToken.new(pair[0], :mark, pair[1])
        }
      )
    end

    # Converts self to flat representation
    # @return[Array<Integer, String>] flat representation of self
    #     Example: [1,'a', 3,'bb']
    def to_flat
      self.map{ |t| [t.position, t.contents] }.flatten
    end

  end

  class RelativeSuspendedTokens

    # Instantiates new instance of self from flat array of token tuples
    # @param[Array<Integer, String>] flat flat representation of AbsoluteSuspendedTokens
    #     Example: [1,'a', 3,'bb']
    # @return[AbsoluteSuspendedTokens]
    def self.from_flat(flat)
      self.new(
        flat.each_slice(2).map { |pair|
          SuspendedToken.new(pair[0], :mark, pair[1])
        }
      )
    end

    # Converts self to flat representation
    # @return[Array<Integer, String>] flat representation of self
    #     Example: [1,'a', 3,'bb']
    def to_flat
      self.map{ |t| [t.position, t.contents] }.flatten
    end

  end

end
