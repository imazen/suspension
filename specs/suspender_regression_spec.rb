require_relative 'helper'

module Suspension

  describe Suspender do

    describe 'regressions' do

      it ":plain_text token doesn't consume trailing whitespace when followed by :header_id" do
        Suspender.new("asdf {#id}", REPOSITEXT_TOKENS).suspend.suspended_tokens.to_flat \
            .must_equal [4," {#id}"]
      end

      it "'***\n' is parsed as horizontal_rule and not emphasis" do
        Suspender.new("***\n", REPOSITEXT_TOKENS).suspend.suspended_tokens.to_flat \
            .must_equal [0,"***\n"]
      end

      it "'***' is parsed as emphasis and not horizontal_rule" do
        Suspender.new("***", REPOSITEXT_TOKENS).suspend.suspended_tokens.to_flat \
            .must_equal [0,"**", 0,"*"]
      end

    end
  end
end
