require_relative 'helper'

module Suspension

  describe AbsoluteSuspendedTokens do

    def tokens(flat)
      AbsoluteSuspendedTokens.from_flat(flat).validate
    end

    def longseq
      tokens([0,"a", 5,"bbb", 5,"ccc", 5,"ddd"])
    end

    describe "adjust_for_diff" do
      it "adjusts for deletions and insertions" do
        tokens([1,"@", 5,'%']).adjust_for_diff([[-1,'a'], [0,'bb'], [1,'cc']]) \
                              .validate.to_flat \
                              .must_equal [0,"@",6,"%"]
      end
    end

    describe "adjust_for_deletions" do
      it "adjusts for a simple deletion" do
        tokens([1,"@"]).adjust_for_deletions([[0,2]]).validate.to_flat \
                       .must_equal [0,"@"]
      end

      it "adjusts subsequent tokens" do
        tokens([5,"@",8,"@"]).adjust_for_deletions([[0,2],[4,5]]).validate.to_flat \
                             .must_equal [2,"@",5,"@"]
      end
    end

    describe "adjust_for_insertions" do
      it "adjusts for a simple insertion" do
        tokens([1,"@"]).adjust_for_insertions([[0,2]]).validate.to_flat.must_equal [3,"@"]
      end

      it "adjusts subsequent tokens" do
        tokens([1,"@",3,"@"]).adjust_for_insertions([[0,2],[2,5]]).validate.to_flat \
                             .must_equal [3,"@",8,"@"]
      end

      it "adjusts touching tokens for affinity=:left" do
        tokens([1,"@"]).adjust_for_insertions([[1,3]], :left).validate.to_flat \
                       .must_equal [1,"@"]
      end

      it "adjusts touching tokens for affinity=:right" do
        tokens([1,"@"]).adjust_for_insertions([[1,3]], :right).validate.to_flat \
                       .must_equal [3,"@"]
      end
    end

    describe "to_relative" do
      it "converts to and from relative form" do
        longseq.to_relative.to_absolute.must_equal(longseq)
      end
    end

    describe "validate" do
      it "raises when given items that are not of type SuspendedToken" do
        lambda {
          AbsoluteSuspendedTokens.new([1,2,3]).validate
        }.must_raise ArgumentError
      end

      it "raises when given items that are not in ascending order" do
        lambda {
          AbsoluteSuspendedTokens.new(
            [1,2,4,3].map{ |e| SuspendedToken.new(e, :a, 'a') }
          ).validate
        }.must_raise ArgumentError
      end
    end

    describe "stable_sort" do
      it "sorts SuspendedTokens by position" do
        AbsoluteSuspendedTokens.new(
          tokens([1,'a', 3,'b', 5,'c']) + \
          tokens([2,'d', 4,'e', 6,'f'])
        ).stable_sort.to_flat.must_equal [1,'a', 2,'d', 3,'b', 4,'e', 5,'c', 6,'f']
      end

      it "maintains SuspendedTokens' original sort order if they have identical position" do
        AbsoluteSuspendedTokens.new(
          tokens([1,'a', 2,'b', 3,'c']) + \
          tokens([1,'d', 2,'e', 3,'f'])
        ).stable_sort.to_flat.must_equal [1,'a', 1,'d', 2,'b', 2,'e', 3,'c', 3,'f']
      end
    end

    describe "assert_ordered_list_of_start_end_pairs" do
      it "raises when given diff_list that contains non-tuples" do
        lambda {
          AbsoluteSuspendedTokens.new([]).send(
            :adjust_for_deletions,
            [[0,3], [8,12], [1]]
          )
        }.must_raise ArgumentError
      end
      it "raises when given diff_list that contains start/stop positions that are not in ascending order" do
        lambda {
          AbsoluteSuspendedTokens.new([]).send(
            :adjust_for_deletions,
            [[0,3], [8,12], [11,14]]
          )
        }.must_raise ArgumentError
      end
    end
  end

end
