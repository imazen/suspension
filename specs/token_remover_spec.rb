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

  end
end
