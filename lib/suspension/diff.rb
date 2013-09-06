module Suspension
  module Diff

    # Expects nested array in form
    # [[0,"Equal text"], [-1, "deleted text"],[1,"inserted text"]]
    # See https://code.google.com/p/google-diff-match-patch/wiki/API
    # returns absolute start/stop values -> [[10,22]] or  [[10,23]].
    # Deletions are relative to original text. Additions are relative to text
    # with deletions already applied.
    def self.convert_diff_match_patch (diff_match_patch_list, segment_type)
      dmp = diff_match_patch_list
      if dmp.any? { |p| !([-1,0,1].include?(p[0]) && p[1].is_a?(String)) }
        raise "diff_match_patch_list must contain an array of number/text pairs. #{dmp.inspect} "
      end
      subset = dmp.reduce([0,[]]) do | result, segment |
        ##Accumulate all matching segments
        result[1] << [result[0], result[0] + segment[1].length] if segment[0] == segment_type
        ##Increment position counter - except for opposte segment type
        result[0] += segment[1].length unless segment[0] == segment_type * -1
        result
      end
      subset[1]
    end

    def self.extract_deletions diff_match_patch_list
      convert_diff_match_patch(diff_match_patch_list, -1)
    end

    def self.extract_additions diff_match_patch_list
      convert_diff_match_patch(diff_match_patch_list, 1)
    end

    private_class_method :convert_diff_match_patch

  end

  class AbsoluteSuspendedTokens

    def with_deletions deletions
      if deletions.any? {|a| a.length != 2} || deletions.flatten.reduce(0) { |result, e| e >= result ? e : false } === false
        raise "Array of ordered begin/end pairs expected"
      end
      AbsoluteSuspendedTokens.new(
        self.map do |token|
          token = token.dup
          #Accumulate all deletions prior to (or overlapping) the token
          token.position -= deletions.reduce(0) do |total, del|
            if del[0] < token.position
              total + [token.position - del[0], del[1] - del[0]].min
            else
              total
            end
          end
          token
        end
      )
    end

    def with_additions additions, affinity = :left
      raise "Unrecognized affinity value #{affinity.inspect}" unless [:left, :right].include? affinity
      if additions.any? {|a| a.length != 2} || additions.flatten.reduce(0){ |result, e| e >= result ? e : false } === false
        raise "Array of ordered begin/end pairs expected"
      end
      AbsoluteSuspendedTokens.new(
        self.map do |token|
          token = token.dup
          #Accumulate all additions prior to (or overlapping) the token
          token.position += additions.reduce(0) do |total, add|
            if (affinity == :left && add[0] < token.position) ||
                (affinity == :right && add[0] <= token.position)
              total + add[1] - add[0]
            else
              total
            end
          end
          token
        end
      )
    end

  end
end
