module Rules
  class Location

    attr_reader :localisations

    def initialize
      @localisations = 1.upto(6).map{ |e| "D#{e}" } + 1.upto(7).map{ |e| "F#{e}" } + 1.upto(9).map{ |e| "L#{e}" }
      @localisations += 1.upto(5).map{ |e| "P#{e}" }
    end

  end
end