module Suspension
  class TokenTypeError < StandardError; end;
  class TokensNotAscendingError < StandardError; end;
  class StartEndPairsTypeError < StandardError; end;
  class DmpNumberTextPairTypeError < StandardError; end;
  class DmpSegmentTypeError < StandardError; end;
  class FilteredTextMismatchError < StandardError; end;
end
