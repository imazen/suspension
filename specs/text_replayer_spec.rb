require_relative 'helper'

module Suspension

  describe TextReplayer do

    it "replays" do
      TextReplayer.new(
        "aabxccnne",
        "aabb@ccnn%@",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).replay.must_equal "aabx@ccnne%@"
    end

    describe 'Regressions' do

      it "description" do
        doc_a_text = [
          "",
          "“Then, And good-night, Watson,”",
          "",
          "II.",
          "",
          "At three o’clock precisely I was at Baker Street, but Holmes had not yet returned.",
          ""
        ].join("\n")
        doc_b_tokens = [
          "",
          "“Then, @%And good-night, Watson,”",
          "",
          "***",
          "###II.",
          "",
          "^^^ {:.rid #rid-4AQlP4lP0xGaDAMF6CwzAQ}",
          "At three o’clock precisely I was at Baker Street, but Holmes had not yet returned.",
          ""
        ].join("\n")
        xpect = doc_b_tokens
        result = Suspension::TextReplayer.new(doc_a_text, doc_b_tokens).replay
        result.must_equal xpect
      end

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
