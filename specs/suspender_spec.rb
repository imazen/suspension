require_relative 'helper'

module Suspension

  describe Suspender do

    it "suspends tokens" do
      result = Suspender.new(
        "aabb@ccnn%@",
        [Token.new(:a, /(?<![\\])@/), Token.new(:b, /(?<![\\])%/)]
      ).suspend
      result.filtered_text.must_equal "aabbccnn"
      result.suspended_tokens.to_flat.must_equal [4,"@",8,"%",8,"@"]
    end

    it "doesn't suspend html entities" do
      result = Suspender.new(
        'aabb&#64;cc@nn&#37;&#64;',
        [Token.new(:a, /(?<![\\])@/), Token.new(:b, /(?<![\\])%/)]
      ).suspend
      result.filtered_text.must_equal 'aabb&#64;ccnn&#37;&#64;'
      result.suspended_tokens.to_flat.must_equal [11,"@"]
    end

  end

end
