require_relative 'helper'

module Suspension

  describe DiffAlgorithm do

    describe "symbol to integer conversion for segment_type" do

      {
        :delete => -1,
        :equal => 0,
        :insert => 1,
        -1 => -1,
        0 => 0,
        1 => 1
      }.each do |from,to|
        it "converts '#{ from }' to '#{ to }'" do
          DiffAlgorithm::SYM_TO_INT_MAP[from].must_equal to
        end
      end

    end

    describe "call" do

      it "returns segment_type -1 for deletion" do
        DiffAlgorithm.new.call('a', '').must_equal [[-1, "a"]]
      end

      it "returns segment_type 0 for equality" do
        DiffAlgorithm.new.call('a', 'a').must_equal [[0, "a"]]
      end

      it "returns segment_type 1 for insertion" do
        DiffAlgorithm.new.call('', 'a').must_equal [[1, "a"]]
      end

    end

  end

end
