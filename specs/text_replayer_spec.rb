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

    describe 'Regressions' do

      it "handles multibyte characters" do
        TextReplayer.new(
          "aaèxéùà…e",
          "aaè@éùà…%@",
          [Token.new(:a, /@/), Token.new(:b, /%/)]
        ).replay.must_equal "aaèx@éùà…e%@"
      end

    end

  end

end
