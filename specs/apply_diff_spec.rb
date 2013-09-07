require_relative 'helper'

module Suspension

  describe RelativeSuspendedTokens do

    def rel_tokens(flat)
      RelativeSuspendedTokens.from_flat(flat).validate
    end

    def longseq
      rel_tokens([0,"a", 5,"bb\r\nb", 0,"cc\tc", 0,"dd\"d", 1,"ff,f"])
    end

    it "roundtrip serializes" do
      RelativeSuspendedTokens.deserialize(longseq.serialize).must_equal longseq
    end

    it "serializes in tab-delimited form with correct escaping" do
      longseq.serialize.must_equal [
        "0\tmark\ta\n",
        "5\tmark\t\"bb\r\nb\"\n",
        "0\tmark\t\"cc\tc\"\n",
        "0\tmark\t\"dd\"\"d\"\n",
        "1\tmark\tff,f\n"
      ].join
    end

  end

  describe AbsoluteSuspendedTokens do

    def tokens(flat)
      AbsoluteSuspendedTokens.from_flat(flat).validate
    end

    def longseq
      tokens([0,"a", 5,"bbb", 5,"ccc", 5,"ddd"])
    end

    it "converts to and from relative form" do
      longseq.to_relative.to_absolute.must_equal(longseq)
    end

    it "applies deletions" do
      tokens([1,"@"]).with_deletions([[0,2]]).validate.to_flat.must_equal [0,"@"]
    end

    describe "apply additions" do

      it "adjusts subsequent tokens" do
        tokens([1,"@",3,"@"]).with_insertions([[0,2],[2,5]]).validate.to_flat.must_equal [3,"@",8,"@"]
        tokens([1,"@"]).with_insertions([[0,2]]).validate.to_flat.must_equal [3,"@"]
      end

      it "adjusts touching tokens for affinity=:left" do
        tokens([1,"@"]).with_insertions([[1,3]], :left).validate.to_flat.must_equal [1,"@"]
      end

      it "adjusts touching tokens for affinity=:right" do
        tokens([1,"@"]).with_insertions([[1,3]], :right).validate.to_flat.must_equal [3,"@"]
      end

    end
  end

  describe Suspension::Diff do

    let(:dmp){ [[0,'aa'], [1,'22'], [-1,'bb'], [0,'cc']]}

    it "extracts deletions" do
      Suspension::Diff.extract_deletions(dmp).must_equal [[2,4]]
    end

    it "extracts additions" do
      Suspension::Diff.extract_insertions(dmp).must_equal [[2,4]]
    end

  end

end
