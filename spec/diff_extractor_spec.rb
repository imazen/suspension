require_relative 'helper'

module Suspension

  describe DiffExtractor do

    describe "extract_deletions" do

      it "extracts simple deletion" do
        #  012
        #  --
        # "aa"
        # ""
        DiffExtractor.extract_deletions(
          [[-1,'aa']]
        ).must_equal [[0,2]]
      end

      it "extracts deletion surrounded by equalities" do
        #  0123456
        #    --
        # "aabbcc"
        # "aacc"
        DiffExtractor.extract_deletions(
          [[0,'aa'], [-1,'bb'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts deletion preceded by insertion" do
        #  0123456
        #    --
        # "aabbcc"
        # "aa22cc"
        DiffExtractor.extract_deletions(
          [[0,'aa'], [1,'22'], [-1,'bb'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts deletion followed by insertion" do
        #  0123456
        #    --
        # "aabbcc"
        # "aa22cc"
        DiffExtractor.extract_deletions(
          [[0,'aa'], [-1,'bb'], [1,'22'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts multiple deletions" do
        #  0123456789
        #    --  --
        # "aabbccdd"
        # "aacc"
        DiffExtractor.extract_deletions(
          [[0,'aa'], [-1,'bb'], [0,'cc'], [-1,'dd']]
        ).must_equal [[2,4], [6,8]]
      end

      it "handles multibyte characters" do
        #  0123456789
        #    --  --
        # "à…à…à…à…"
        # "à…à…"
        DiffExtractor.extract_deletions(
          [[0,'à…'], [-1,'à…'], [0,'à…'], [-1,'à…']]
        ).must_equal [[2,4], [6,8]]
      end

    end

    describe "extract_insertions" do

      it "extracts simple insertion" do
        #  012
        #  ++
        # ""
        # "bb"
        DiffExtractor.extract_insertions(
          [[1,'bb']]
        ).must_equal [[0,2]]
      end

      it "extracts insertion surrounded by equalities" do
        #  0123456
        #    ++
        # "aacc"
        # "aabbcc"
        DiffExtractor.extract_insertions(
          [[0,'aa'], [1,'bb'], [0,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts insertion followed by deletion" do
        #  0123456
        #    ++
        # "aacc"
        # "aabb"
        DiffExtractor.extract_insertions(
          [[0,'aa'], [1,'bb'], [-1, 'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts insertion preceded by deletion" do
        #  0123456
        #    ++
        # "aabb"
        # "aacc"
        DiffExtractor.extract_insertions(
          [[0,'aa'], [-1, 'bb'], [1,'cc']]
        ).must_equal [[2,4]]
      end

      it "extracts multiple insertions" do
        #  0123456789
        #    ++  ++
        # "aacc"
        # "aabbccdd"
        DiffExtractor.extract_insertions(
          [[0,'aa'], [1, 'bb'], [0, 'cc'], [1,'dd']]
        ).must_equal [[2,4], [6,8]]
      end

    end

    describe "convert_diff_match_patch" do

      it "raises when given diff_match_patch_list with invalid segment_type" do
        lambda {
          DiffExtractor.extract_deletions([[nil,'a']])
        }.must_raise(DmpNumberTextPairTypeError)
      end

      it "raises when given diff_match_patch_list with invalid text" do
        lambda {
          DiffExtractor.extract_deletions([[-1,nil]])
        }.must_raise(DmpNumberTextPairTypeError)
      end

      it "raises when given invalid segment_type" do
        lambda {
          DiffExtractor.convert_diff_match_patch([[-1,'a']], 'invalid')
        }.must_raise(DmpSegmentTypeError)
      end

    end

  end

end
