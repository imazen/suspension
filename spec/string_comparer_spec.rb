require_relative 'helper'

module Suspension

  describe StringComparer do

    describe '.compare with default options' do

      [
        [
          'identical_strings',
          'identical_strings',
          []
        ],
        [
          'word word word word word word word word word word',
          'word word word word word ++++++++++ word word word word word',
          [[1, "++++++++++ ", "line 1", "word word word word ++++++++++ word word"]]
        ],
        [
          'word word word word word deleted word word word',
          'word word word word word word word word',
          [[-1, "deleted ", "line 1", "word word word word deleted word word wo"]]
        ],
        [
          'word word word xxxx word word word',
          'word word word yyyy word word word',
          [
            [-1, "xxxx", "line 1", "word word word xxxx word word word"],
            [1,  "yyyy", "line 1", "word word word yyyy word word word"]
          ]
        ],
        [
          "line1\nline2\nline3\nline4\nline5\nline6",
          "line1\nline2\nline3\nline4 added\nline5\nline6",
          [[1, " added", "line 4", "e1\nline2\nline3\nline4 added\nline5\nline6"]]
        ],
        [
          'unicode chars — emdash',
          'unicode chars emdash',
          [[-1, "— ", "line 1", "unicode chars — emdash"]]
        ],
        [
          'multibyte char alignment — one multibyte char is emdash, the other elipsis',
          'multibyte char alignment … one multibyte char is emdash, the other elipsis',
          [
            [-1, "—", "line 1", "byte char alignment — one multibyte char"],
            [1, "…", "line 1", "byte char alignment … one multibyte char"],
          ]
        ],
        [
          '— multibyte char at pos 0',
          '… multibyte char at pos 0',
          [
            [-1, "—", "line 1", "— multibyte char at "],
            [1, "…", "line 1", "… multibyte char at "]
          ]
        ],
        [
          'a— multibyte char at pos 1',
          'a… multibyte char at pos 1',
          [
            [-1, "—", "line 1", "a— multibyte char at "],
            [1, "…", "line 1", "a… multibyte char at "]
          ]
        ],
        [
          'ab— multibyte char at pos 2',
          'ab… multibyte char at pos 2',
          [
            [-1, "—", "line 1", "ab— multibyte char at "],
            [1, "…", "line 1", "ab… multibyte char at "]
          ]
        ],
        [
          'abc— multibyte char at pos 3',
          'abc… multibyte char at pos 3',
          [
            [-1, "—", "line 1", "abc— multibyte char at "],
            [1, "…", "line 1", "abc… multibyte char at "]
          ]
        ],
        [
          'abcd— multibyte char at pos 4',
          'abcd… multibyte char at pos 4',
          [
            [-1, "—", "line 1", "abcd— multibyte char at "],
            [1, "…", "line 1", "abcd… multibyte char at "]
          ]
        ],
        [
          'abcde— multibyte char at pos 5',
          'abcde… multibyte char at pos 5',
          [
            [-1, "—", "line 1", "abcde— multibyte char at "],
            [1, "…", "line 1", "abcde… multibyte char at "]
          ]
        ],
        [
          'abcdef— multibyte char at pos 6',
          'abcdef… multibyte char at pos 6',
          [
            [-1, "—", "line 1", "abcdef— multibyte char at "],
            [1, "…", "line 1", "abcdef… multibyte char at "]
          ]
        ],
        [
          "word1 word2a—word2b…word3 word4 word5",
          "word1 word2b…word3 word4",
          [
            [-1, "a—word2", "line 1", "word1 word2a—word2b…word3 word4"],
            [-1, " word5", "line 1", "a—word2b…word3 word4 word5"]
          ]
        ],
        [
          "line1 word1 word2a word3\nline2 word4 word5 word6\nline3 word7 word8 word9",
          "line1 word1 word2b word3\nline2 word5 word6\nline3 word7 word7b word8 word9",
          [
            [-1, "a", "line 1", "line1 word1 word2a word3\nline2 word4 "],
            [1, "b", "line 1", "line1 word1 word2b word3\nline2 word5 "],
            [-1, " word4", "line 2", "1 word2a word3\nline2 word4 word5 word6\nl"],
            [1, " word7b", "line 3", "d5 word6\nline3 word7 word7b word8 word9"]
          ]
        ],
      ].each do |(string_1, string_2, xpect)|
        it "handles #{ string_1.inspect } -> #{ string_2.inspect }" do
          Suspension::StringComparer.compare(string_1, string_2).must_equal(xpect)
        end

      end

    end

    describe '.compare without context_info' do

      it "returns no context info" do
        Suspension::StringComparer.compare(
          "word1 word2 word3",
          "word1 word2 word3 word4",
          false
        ).must_equal([[1, " word4"]])
      end

    end

    describe '.compare with context_info and all diff segments' do

      it "returns all diff segments" do
        Suspension::StringComparer.compare(
          "word1 word2 word3",
          "word1 word2 word3 word4",
          true,
          false
        ).must_equal(
          [
            [0, "word1 word2 word3", "line 1", nil],
            [1, " word4", "line 1", "word1 word2 word3 word4"]
          ]
        )
      end

    end

    describe '.compare with option :excerpt_window' do

      it "returns excerpt with expected length" do
        Suspension::StringComparer.compare(
          "word1 word2 word3",
          "word1 word2 word3 word4",
          true,
          false,
          { excerpt_window: 5 }
        ).must_equal(
          [
            [0, "word1 word2 word3", "line 1", nil],
            [1, " word4", "line 1", "word3 word"]
          ]
        )
      end

    end

  end
end
