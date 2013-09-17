require_relative '../helper'

module Suspension
  module Workflow
    describe ConvertAtToPt do

      it "converts" do
        ConvertAtToPt.new(
          "^^^\n{:.rid}\n*emphasis* @normal %paragraph",
        ).run.must_equal "*emphasis* normal paragraph"
      end

    end
  end
end
