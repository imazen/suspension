require_relative 'helper'

module Suspension

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

    describe "adjust_for_diff" do

      it "adjusts for deletions and insertions" do
        tokens([1,"@", 5,'%']).adjust_for_diff([[-1,'a'], [0,'bb'], [1,'cc']]) \
                              .validate.to_flat \
                              .must_equal [0,"@",6,"%"]
      end

    end

    describe "adjusted_for_deletions" do

      it "adjusts for a simple deletion" do
        tokens([1,"@"]).adjusted_for_deletions([[0,2]]).validate.to_flat \
                       .must_equal [0,"@"]
      end

      it "adjusts subsequent tokens" do
        tokens([5,"@",8,"@"]).adjusted_for_deletions([[0,2],[4,5]]).validate.to_flat \
                             .must_equal [2,"@",5,"@"]
      end

    end

    describe "adjusted_for_insertions" do

      it "adjusts for a simple insertion" do
        tokens([1,"@"]).adjusted_for_insertions([[0,2]]).validate.to_flat.must_equal [3,"@"]
      end

      it "adjusts subsequent tokens" do
        tokens([1,"@",3,"@"]).adjusted_for_insertions([[0,2],[2,5]]).validate.to_flat \
                             .must_equal [3,"@",8,"@"]
      end

      it "adjusts touching tokens for affinity=:left" do
        tokens([1,"@"]).adjusted_for_insertions([[1,3]], :left).validate.to_flat \
                       .must_equal [1,"@"]
      end

      it "adjusts touching tokens for affinity=:right" do
        tokens([1,"@"]).adjusted_for_insertions([[1,3]], :right).validate.to_flat \
                       .must_equal [3,"@"]
      end

    end

  end

end
