require_relative 'helper'

module Suspension

  describe TokenReplacer do

    it "replaces a single token_name" do
      TokenReplacer.new(
        "aab@bccnn%",
        "aabbc@cnn@",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).replace([:a]).must_equal "aabbc@cnn%@"
    end

    it "replaces multiple token names" do
      TokenReplacer.new(
        "aab@bccnn%",
        "aabbc@cnn@",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).replace([:a, :b]).must_equal "aabbc@cnn@"
    end

  end

end
