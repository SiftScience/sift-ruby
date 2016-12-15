module Sift
  module Utils
    class HashGetter
      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def get(value)
        hash[value.to_sym] || hash[value.to_s]
      end
    end
  end
end
