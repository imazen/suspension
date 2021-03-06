require_relative 'helper'

module Suspension

  describe Suspender do

    it "suspends tokens" do
      result = Suspender.new(
        #01234456788
        "aabb@ccnn%@",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).suspend
      result.filtered_text.must_equal "aabbccnn"
      result.suspended_tokens.to_flat.must_equal [4,"@",8,"%",8,"@"]
    end

    it "doesn't suspend simple html entities" do
      result = Suspender.new(
        'and &#42;extraordinary&#42; powers',
        Suspension::REPOSITEXT_TOKENS
      ).suspend
      result.filtered_text.must_equal 'and &#42;extraordinary&#42; powers'
      result.suspended_tokens.to_flat.must_equal []
    end

    it "doesn't suspend html entities mixed with tokens" do
      result = Suspender.new(
        #01234567890112345
        'aabb&#64;cc@nn&#37;&#64;',
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).suspend
      result.filtered_text.must_equal 'aabb&#64;ccnn&#37;&#64;'
      result.suspended_tokens.to_flat.must_equal [11,"@"]
    end

    it "handles strings with multibyte characters (1)" do
      result = Suspender.new(
        #01234567
        "èì—éùà…@",
        [Token.new(:a, /@/)]
      ).suspend
      result.filtered_text.must_equal "èì—éùà…"
      result.suspended_tokens.to_flat.must_equal [7, '@']
    end

    it "handles strings with multibyte characters (2)" do
      result = Suspender.new(
        " Messaggio entusiasmante",
        [Token.new(:a, /@/)]
      ).suspend
      result.filtered_text.must_equal " Messaggio entusiasmante"
      result.suspended_tokens.to_flat.must_equal []
    end

    it "removes headers after subtitle marks" do
      result = Suspender.new("@# header", Suspension::REPOSITEXT_TOKENS).suspend
      result.filtered_text.must_equal "header"
    end

    it "does not remove headers after plain text (they are not at beginning of line)" do
      result = Suspender.new(" # header", Suspension::REPOSITEXT_TOKENS).suspend
      result.filtered_text.must_equal " # header"
    end

    [
      # 0123456789 0 0000 1 2
      ["some text\n\n^^^\n\nmore text", "some text\n\nmore text", [10, "\n^^^\n"]],
      # 0123456789 9999 0 12
      ["some text\n^^^\n\nmore text", "some text\nmore text", [9, "\n^^^\n"]],
      # 0123456789 9999 012
      ["some text\n^^^\nmore text", "some textmore text", [9, "\n^^^\n"]],
    ].each do |(test_string, xpect_ft, xpect_st)|
      it "completely removes block tokens from filtered text (with leading and trailing \\n): #{ test_string.inspect }" do
        result = Suspender.new(
          test_string,
          Suspension::REPOSITEXT_TOKENS
        ).suspend
        result.suspended_tokens.to_flat.must_equal xpect_st
        result.filtered_text.must_equal xpect_ft
      end
    end
  end

end
