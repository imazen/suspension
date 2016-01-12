require_relative 'helper'

module Suspension

  describe StringComparer do

    describe 'test cases' do

      [
        [
          'identical_strings',
          'identical_strings',
          []
        ],
        [
          'word word word word word word',
          'word word word added word word word',
          [[1, "added ", "line 1", "word word word added word word"]]
        ],
        [
          'word word word deleted word word word',
          'word word word word word word',
          [[-1, "deleted ", "line 1", "word word word deleted word word word"]]
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
          [[1, " added", "line 4", "e1\nline2\nline3\nline4 added\nline5\n"]]
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
            [-1, "—", "line 1", "byte char alignment — one multibyte char i"],
            [1, "…", "line 1", "yte char alignment … one multibyte char is"],
          ]
        ],
        [
          '— multibyte char at pos 0',
          '… multibyte char at pos 0',
          [
            [-1, "—", "line 1", "— multibyte char at po"],
            [1, "…", "line 1", "… multibyte char at pos"]
          ]
        ],
        [
          'a— multibyte char at pos 1',
          'a… multibyte char at pos 1',
          [
            [-1, "—", "line 1", "a— multibyte char at po"],
            [1, "…", "line 1", "a… multibyte char at pos"]
          ]
        ],
        [
          'ab— multibyte char at pos 2',
          'ab… multibyte char at pos 2',
          [
            [-1, "—", "line 1", "ab— multibyte char at po"],
            [1, "…", "line 1", "ab… multibyte char at pos"]
          ]
        ],
        [
          'abc— multibyte char at pos 3',
          'abc… multibyte char at pos 3',
          [
            [-1, "—", "line 1", "abc— multibyte char at po"],
            [1, "…", "line 1", "abc… multibyte char at pos"]
          ]
        ],
        [
          'abcd— multibyte char at pos 4',
          'abcd… multibyte char at pos 4',
          [
            [-1, "—", "line 1", "abcd— multibyte char at po"],
            [1, "…", "line 1", "abcd… multibyte char at pos"]
          ]
        ],
        [
          'abcde— multibyte char at pos 5',
          'abcde… multibyte char at pos 5',
          [
            [-1, "—", "line 1", "abcde— multibyte char at po"],
            [1, "…", "line 1", "abcde… multibyte char at pos"]
          ]
        ],
        [
          'abcdef— multibyte char at pos 6',
          'abcdef… multibyte char at pos 6',
          [
            [-1, "—", "line 1", "abcdef— multibyte char at po"],
            [1, "…", "line 1", "abcdef… multibyte char at pos"]
          ]
        ],
        [
          "word1 word2—word2…word3 word4 word5",
          "word1 word2…word3 word4",
          [
            [-1, "—word2", "line 1", "word1 word2—word2…word3 word4 word5"],
            [-1, " word5", "line 1", "d2—word2…word3 word4 word5"]
          ]
        ],
      ].each do |(string_1, string_2, xpect)|
        it "handles #{ string_1.inspect } -> #{ string_2.inspect }" do
          Suspension::StringComparer.compare(string_1, string_2).must_equal(xpect)
        end
      end
    end

  end
end
