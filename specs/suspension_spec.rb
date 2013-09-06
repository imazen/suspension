require_relative 'helper'

module Suspension

  describe Suspender do

    it "suspends tokens" do
      # TODO: why are @ and % in Token regex escaped?
      result = Suspender.new(
        "aabb@ccnn%@",
        [Token.new(:a, /(?<![\\])\@/), Token.new(:b, /(?<![\\])\%/)]
      ).suspend
      result.filtered_text.must_equal "aabbccnn"
      result.matched_tokens.to_flat.must_equal [4,"@",8,"%",8,"@"]
    end

  end

  describe Unsuspender do

    it "restores tokens" do
      un  = Unsuspender.new(
        "aabbccnn",
        AbsoluteSuspendedTokens.from_flat([4,"@",8,"%",8,"@"])
      )
      un.restore.must_equal "aabb@ccnn%@"
    end

  end

end
