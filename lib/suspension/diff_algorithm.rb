module Suspension
  class DiffAlgorithm

    SYM_TO_INT_MAP = {
      :delete => -1,
      :equal => 0,
      :insert => 1
    }

    def call(a,b)
      # convert dmp output from
      # [[:delete, "a"], [:equal, "ab"], [:delete, "b"], [:insert, "x"], [:equal, "ccnn"], [:insert, "e"]]
      # to
      # [[-1, "a"], [0, "ab"], [-1, "b"], [1, "x"], [0, "ccnn"], [1, "e"]]
      DiffMatchPatch.new.diff_main(a,b).map { |e|
        segment_type = SYM_TO_INT_MAP[e[0]] || e[0]
        [segment_type, e[1]]
      }
    end

  end

end
