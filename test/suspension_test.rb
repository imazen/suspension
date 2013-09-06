require 'suspension'
require 'suspension/test_helpers'
require 'minitest/autorun'
require 'minitest/spec/expect'

module Suspension

  describe Suspender do

    it "should suspend tokens" do
      result = Suspender.new("aabb@ccnn%@",[Token.new(:a,/(?<![\\])\@/),Token.new(:b,/(?<![\\])\%/)]).suspend
      expect(result.filtered_text).to_equal "aabbccnn"
      expect(result.matched_tokens.to_flat).to_equal [4,"@",8,"%",8,"@"]
    end

  end

  describe Unsuspender do

    it "should restore tokens" do
      un  = Unsuspender.new("aabbccnn", AbsoluteSuspendedTokens.from_flat([4,"@",8,"%",8,"@"]))
      expect(un.restore).to_equal "aabb@ccnn%@"
    end

  end

end
