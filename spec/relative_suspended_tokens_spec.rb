require_relative 'helper'

module Suspension

  describe RelativeSuspendedTokens do

    def rel_tokens(flat)
      RelativeSuspendedTokens.from_flat(flat).validate
    end

    def longseq
      rel_tokens([0,"a…", 5,"bb\r\nb", 0,"cc\tc", 0,"dd\"d", 1,"ff,f"])
    end

    it "converts to and from absolute form" do
      longseq.to_absolute.to_relative.must_equal(longseq)
    end

    it "roundtrip serializes" do
      RelativeSuspendedTokens.deserialize(longseq.serialize).must_equal longseq
    end

    it "serializes in tab-delimited form with correct escaping" do
      longseq.serialize.must_equal [
        "0\tmark\ta…\n",
        "5\tmark\t\"bb\r\nb\"\n",
        "0\tmark\t\"cc\tc\"\n",
        "0\tmark\t\"dd\"\"d\"\n",
        "1\tmark\tff,f\n"
      ].join
    end

  end

end
