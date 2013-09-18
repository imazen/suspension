require_relative 'helper'

module Suspension

  describe TextReplayer do

    it "replays" do
      TextReplayer.new(
        "aabxccnne",
        "aabb@ccnn%@",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).replay.must_equal "aab@xccnn%@e"
    end

  end

end
