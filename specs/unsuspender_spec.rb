require_relative 'helper'

module Suspension

  describe Unsuspender do

    it "restores tokens" do
      un = Unsuspender.new(
        "aabbccnn",
        AbsoluteSuspendedTokens.from_flat([4,"@",8,"%",8,"@"])
      )
      un.restore.must_equal "aabb@ccnn%@"
    end

  end

end
