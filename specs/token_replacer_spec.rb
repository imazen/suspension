require_relative 'helper'

module Suspension

  describe TokenReplacer do

    it "replays" do
      TokenReplacer.new(
        "aab@bccnn%",
        "aabbc@cnn@",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).replace([:a]).must_equal "aabbc@cnn%@"
    end

  end

end
