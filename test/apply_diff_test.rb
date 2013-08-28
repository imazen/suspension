require 'suspension'
require 'minitest/autorun'

describe RelativeSuspendedTokens do
    before do
        @tokens = RelativeSuspendedTokens.new ([SuspendedToken.new(1,:mark, "@")])
    end

    it "should apply deletions correctly" do
        @tokens.with_deletions([0,2]).must_equal([SuspendedToken.new(0,:mark, "@")])
    end

    it "should apply additions correctly" do

    end
end