require_relative 'helper'

module Suspension

  describe DiffAlgorithm do

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
