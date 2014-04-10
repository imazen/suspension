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

    it "handles strings with multibyte characters" do
      un = Unsuspender.new(
        "èì—éùà… abcde èì—éùà… èì—éùà…",
        AbsoluteSuspendedTokens.from_flat([7,"@",14,"@",18,"@"])
      )
      un.restore.must_equal "èì—éùà…@ abcde @èì—é@ùà… èì—éùà…"
    end

  end

end
