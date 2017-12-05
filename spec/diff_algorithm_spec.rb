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

      it "handles strings with multibyte characters" do
        DiffAlgorithm.new.call('', 'à').must_equal [[1, "à"]]
      end

      describe "utf8 awareness" do

        # We use the following chars to test the various scenarios:
        #
        # Char   Code    UTF-8
        # ----------------------
        # Same start byte
        # Г      0413    D0 93
        # Д      0414    D0 94
        # Same multiple start bytes
        # ╫      256B    E2 95 AB
        # ╭      256D    E2 95 AD
        # Same end byte
        # Ы      042B    D0 AB
        # ѫ      046B    D1 AB
        # Same multiple end bytes
        # ╫      256B    E2 95 AB
        # ᕫ      156B    E1 95 AB
        # Same start and end bytes
        # ╫      256B    E2 95 AB
        # ┫      252B    E2 94 AB
        # Same middle byte
        # ╫      256B    E2 95 AB
        # ᕬ      156C    E1 95 AC
        #
        # This tool is useful for finding unicode chars by their utf8 encoded bytes:
        # https://r12a.github.io/apps/conversion/

        # NOTE: I need a difference at the beginning of each test string to disable
        # dmp's line_checking which bypasses the issue. Hence the `a` and `b`
        # start to each test string.
        [
          [
            "handles diff with same start byte",
            "a Г ",
            "b Д ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "Г"], [1, "Д"], [0, " "]]
          ],
          [
            "handles diff with same multiple start bytes",
            "a ╫ ",
            "b ╭ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "╫"], [1, "╭"], [0, " "]]
          ],
          [
            "handles multiple diffs with same start byte each",
            "a Г word Г ",
            "b Д werd Д ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "Г"], [1, "Д"], [0, " w"], [-1, "o"], [1, "e"], [0, "rd "], [-1, "Г"], [1, "Д"], [0, " "]]
          ],

          [
            "handles diff with same end byte",
            "a Ы ",
            "b ѫ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "Ы"], [1, "ѫ"], [0, " "]]
          ],
          [
            "handles diff with same multiple end bytes",
            "a ╫ ",
            "b ᕫ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "╫"], [1, "ᕫ"], [0, " "]]
          ],
          [
            "handles multiple diffs with same end byte each",
            "a Ы word Ы ",
            "b ѫ werd ѫ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "Ы"], [1, "ѫ"], [0, " w"], [-1, "o"], [1, "e"], [0, "rd "], [-1, "Ы"], [1, "ѫ"], [0, " "]]
          ],

          [
            "handles diff with same start and end bytes",
            "a ╫ ",
            "b ┫ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "╫"], [1, "┫"], [0, " "]]
          ],
          [
            "handles multiple diffs with same start and end bytes each",
            "a ╫ word ╫ ",
            "b ┫ werd ┫ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "╫"], [1, "┫"], [0, " w"], [-1, "o"], [1, "e"], [0, "rd "], [-1, "╫"], [1, "┫"], [0, " "]]
          ],

          [
            "handles diff with same middle byte",
            "a ╫ ",
            "b ᕬ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "╫"], [1, "ᕬ"], [0, " "]]
          ],
          [
            "handles multiple diffs with same middle byte each",
            "a ╫ word ╫ ",
            "b ᕬ werd ᕬ ",
            [[-1, "a"], [1, "b"], [0, " "], [-1, "╫"], [1, "ᕬ"], [0, " w"], [-1, "o"], [1, "e"], [0, "rd "], [-1, "╫"], [1, "ᕬ"], [0, " "]]
          ],

          [
            "handles insertion with same start byte",
            "a Г ",
            "b ДГ ",
            [[-1, "a"], [1, "b"], [0, " "], [1, "Д"], [0, "Г "]]
          ],
          [
            "handles insertion with same end byte",
            "a Ы ",
            "b Ыѫ ",
            [[-1, "a"], [1, "b"], [0, " Ы"], [1, "ѫ"], [0, " "]]
          ],

          [
            "handles deletion with same start byte",
            "a ГД ",
            "b Г ",
            [[-1, "a"], [1, "b"], [0, " Г"], [-1, "Д"], [0, " "]]
          ],
          [
            "handles deletion with same end byte",
            "a Ыѫ ",
            "b Ы ",
            [[-1, "a"], [1, "b"], [0, " Ы"], [-1, "ѫ"], [0, " "]]
          ],
        ].each do |desc, string_a, string_b, xpect|
          it desc do
            DiffAlgorithm.new.call(string_a, string_b).must_equal(xpect)
          end
        end
      end
    end

  end
end
