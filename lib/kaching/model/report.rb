# frozen_string_literal: true

module Kaching
  module Model
    # A report of multiple transactions on a single day
    class Report
      # @return [Date]
      attr_reader :date
      # @return [Array<Transaction>]
      attr_reader :transactions

      # @param date [Date]
      # @param transactions [Array<Transaction>]
      def initialize(date:, transactions:)
        @date = date.freeze
        @transactions = transactions.freeze
        freeze
      end

      # @return [Integer]
      def units
        @transactions.sum(&:units)
      end

      # @return [Hash<String,Numeric>]
      def amounts
        @transactions.each_with_object(Hash.new(0)) do |t, acc|
          acc[t.currency] += t.units * t.value
        end
      end

      def to_s
        "#{date}: #{amounts}"
      end
    end
  end
end
