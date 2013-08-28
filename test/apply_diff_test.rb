require 'suspension'
require 'minitest/autorun'
require 'minitest/spec/expect'

module Suspension

    class AbsoluteSuspendedTokens
        def to_flat 
            self.map{ |t| [t.position, t.contents]}.flatten
        end
        def self.from_flat flat
            self.new flat.each_slice(2).map {|pair| SuspendedToken.new pair[0], :mark, pair[1]}
        end
    end
    class RelativeSuspendedTokens
        def to_flat 
            self.map{ |t| [t.position, t.contents]}.flatten
        end
        def self.from_flat flat
            self.new flat.each_slice(2).map {|pair| SuspendedToken.new pair[0], :mark, pair[1]}
        end
    end


    describe AbsoluteSuspendedTokens do

        def tokens flat
            AbsoluteSuspendedTokens.from_flat(flat).validate
        end


        it "apply deletions" do
            tokens([1,"@"]).with_deletions([[0,2]]).validate.to_flat.must_equal [0,"@"]
        end

        describe "apply additions" do

            it "adjust subsequent tokens" do
                tokens([1,"@",3,"@"]).with_additions([[0,2],[2,5]]).validate.to_flat.must_equal [3,"@",8,"@"]
                tokens([1,"@"]).with_additions([[0,2]]).validate.to_flat.must_equal [3,"@"]
            end

            it "adjust touching tokens for affinity=:left" do
                tokens([1,"@"]).with_additions([[1,3]], :left).validate.to_flat.must_equal [1,"@"]
            end
            it "adjust touching tokens for affinity=:right" do
                tokens([1,"@"]).with_additions([[1,3]], :right).validate.to_flat.must_equal [3,"@"]
            end
        end
    end

    describe Suspension::Diff do
        let(:dmp){ [[0,'aa'],[1,'22'],[-1,'bb'],[0,'cc']]}

        it "should extract deletions" do
            expect(Suspension::Diff.extract_deletions(dmp)).to_equal [[2,4]]
        end

        it "should extract additions" do
            expect(Suspension::Diff.extract_additions(dmp)).to_equal [[2,4]]
        end

    end

end


