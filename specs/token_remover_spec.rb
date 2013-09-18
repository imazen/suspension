require_relative 'helper'

module Suspension
  describe TokenRemover do

    it "removes tokens" do
      TokenRemover.new(
        "^^^\n{:.rid}\n*emphasis* @normal %paragraph"
      ).remove.must_equal "*emphasis* normal paragraph"
    end

  end
end
