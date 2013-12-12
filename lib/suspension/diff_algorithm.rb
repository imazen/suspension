module Suspension
  class DiffAlgorithm

    # The ruby diff_match_patch gem returns symbols instead of integers for the
    # segment type. This hash converts the symbols to the corresponding integers
    # so that we can use the standard DMP API higher up the call stack.
    # It returns nil for unexpected keys.
    SYM_TO_INT_MAP = {
      :delete => -1,
      :equal => 0,
      :insert => 1,
      -1 => -1,
      0 => 0,
      1 => 1
    }

    # Generates a diff to transform a to b
    # @param[String] a the 'from' text
    # @param[String] b the 'to' text
    # @return[Array<Array>] diff_match_patch_list an array of tuples where the
    #     first item is the segment type (-1 for deletion, 0 for equality, 1 for
    #     insertion) and the second item is the segment content as string:
    #     Example: [[-1, "a"], [0, "ab"], [-1, "b"], [1, "x"], [0, "ccnn"], [1, "e"]]
    def call(a,b)
      # convert dmp output from
      # [[:delete, "a"], [:equal, "ab"], [:delete, "b"], [:insert, "x"], [:equal, "ccnn"], [:insert, "e"]]
      # to
      # [[-1, "a"], [0, "ab"], [-1, "b"], [1, "x"], [0, "ccnn"], [1, "e"]]
      dmp = DiffMatchPatch.new

      dmp.diff_timeout = 0
      dmp.diff_edit_cost = 10 if dmp.respond_to? :diff_edit_cost
      dmp.diff_editCost = 10 if dmp.respond_to? :diff_editCost


      dmp.diff_main(a,b,false).map { |e|
        [SYM_TO_INT_MAP[e[0]], e[1]]
      }
    end

  end

end
