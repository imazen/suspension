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

      it "handles sherlock" do
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
          "",
          "***",
          "###II.",
          "",
          "",
          "^^^ {:.rid #rid-4AQlP4lP0xGaDAMF6CwzAQ}",
          "At three o’clock precisely I was at Baker Street, but Holmes had not yet returned.",
          ""
        ].join("\n")
        xpect = doc_b_tokens
        result = Suspension::TextReplayer.new(doc_a_text, doc_b_tokens).replay
        result.must_equal xpect
      end

      it "handles record ids" do
        doc_a_text = [
          "",
          "Here is authoritative text",
          ""
        ].join("\n")
        doc_b_tokens = [
          "^^^{:.rid #rid-65020019}",
          "",
          "Here is updatable text",
          ""
        ].join("\n")
        xpect = [
          "^^^{:.rid #rid-65020019}",
          "",
          "Here is authoritative text",
          ""
        ].join("\n")
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

      it "handles deletion overlapping single token" do
        TextReplayer.new(
          "aacc",
          "aabb@bbcc",
          [Token.new(:a, /@/)]
        ).replay.must_equal "aa@cc"
      end

      it "handles deletion overlapping multiple tokens" do
        TextReplayer.new(
          "aacc",
          "aabb@bb@bbcc",
          [Token.new(:a, /@/)]
        ).replay.must_equal "aa@@cc"
      end

      it "handles insertion overlapping single token" do
        TextReplayer.new(
          "aabbbbcc",
          "aa@cc",
          [Token.new(:a, /@/)]
        ).replay.must_equal "aabbbb@cc"
      end

    end

  end

end
