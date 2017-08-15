require_relative 'helper'

module Suspension
  describe TokenRemover do

    it "removes at-specific tokens by default" do
      TokenRemover.new(
        "\n^^^\n{:.rid}\n*emphasis* @normal %paragraph"
      ).remove.must_equal "*emphasis* normal paragraph"
    end

    it "removes custom tokens" do
      TokenRemover.new(
        "^^^\n{:.rid}\n*emphasis* @normal %paragraph",
        [Token.new(:a, /@/), Token.new(:b, /%/)]
      ).remove.must_equal "^^^\n{:.rid}\n*emphasis* normal paragraph"
    end

    describe 'REPOSITEXT_TOKENS' do
      [
        [
          'Level 3 header between two paragraphs',
          "word1\n{: .normal}\n\n### word2\n{: .normal}\n\nword3",
          "word1\nword2\nword3",
        ],
        [
          'Level 1 header with inline IAL',
          "# *word1*{: .italic}\n\nword2\n{: .class}",
          "word1\n\nword2\n",
        ],
        [
          'Level 1 header without inline IAL',
          "# *word1*\n\nword2\n{: .class}",
          "word1\n\nword2\n",
        ],
        [
          'Level 1 header with leading subtitle mark',
          "@# *word1*{: .italic}\n",
          "word1\n",
        ],
      ].each do |description, input, xpect|
        it "handles #{ description }" do
          TokenRemover.new(
            input,
            Suspension::REPOSITEXT_TOKENS
          ).remove.must_equal(xpect)
        end
      end
    end

  end
end
