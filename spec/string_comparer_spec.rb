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
            [-1, "multibyte char alignment —", "line 1", "multibyte char alignment — one multibyte char i"],
            [1, "multibyte char alignment …", "line 1", "yte char alignment … one multibyte char is emdash, the other elipsi"]
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
