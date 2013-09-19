require_relative 'helper'

module Suspension

  describe DiffExtractor do

    describe "extract_deletions" do

      it "extracts simple deletion" do
        DiffExtractor.extract_deletions(
          [[-1,'aa']]
        ).must_equal [[0,2]]
      end

      it "extracts deletion surrounded by equalities" do
        DiffExtractor.extract_deletions(
          [[0,'aa'], [-1,'bb'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts deletion preceded by insertion" do
        DiffExtractor.extract_deletions(
          [[0,'aa'], [1,'22'], [-1,'bb'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts deletion followed by insertion" do
        DiffExtractor.extract_deletions(
          [[0,'aa'], [-1,'bb'], [1,'22'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts multiple deletions" do
        DiffExtractor.extract_deletions(
          [[0,'aa'], [-1,'bb'], [0,'cc'], [-1,'dd']]
        ).must_equal [[2,4], [6,8]]
      end

    end

    describe "extract_insertions" do

      it "extracts simple insertion" do
        DiffExtractor.extract_insertions(
          [[1,'bb']]
        ).must_equal [[0,2]]
      end

      it "extracts insertion surrounded by equalities" do
        DiffExtractor.extract_insertions(
          [[0,'aa'], [1,'bb'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts insertion followed by deletion" do
        DiffExtractor.extract_insertions(
          [[0,'aa'], [1,'bb'], [-1, 'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts insertion preceded by deletion" do
        DiffExtractor.extract_insertions(
          [[0,'aa'], [-1, 'bb'], [1,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts multiple insertions" do
        DiffExtractor.extract_insertions(
          [[0,'aa'], [1, 'bb'], [0, 'cc'], [1,'dd']]
        ).must_equal [[2,4], [6,8]]
      end

    end

    describe "convert_diff_match_patch" do

      it "raises when given diff_match_patch_list with invalid segment_type" do
        lambda {
          DiffExtractor.extract_deletions([nil,'a'], -1)
        }.must_raise(ArgumentError)
      end

      it "raises when given diff_match_patch_list with invalid text" do
        lambda {
          DiffExtractor.extract_deletions([-1,nil], -1)
        }.must_raise(ArgumentError)
      end

      it "raises when given invalid segment_type" do
        lambda {
          DiffExtractor.extract_deletions([-1,'a'], 'invalid')
        }.must_raise(ArgumentError)
      end

    end

  end

end
