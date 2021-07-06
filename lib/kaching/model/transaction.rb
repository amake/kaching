# frozen_string_literal: true

module Kaching
  module Model
    # A single transaction
    class Transaction
      # @return [Integer]
      attr_reader :units
      # @return [String]
      attr_reader :currency
      # @return [Numeric]
      attr_reader :value

      # @param units [Integer]
      # @param currency [String]
      # @param value [Numeric]
      def initialize(units:, currency:, value:)
        @units = units.freeze
        @currency = currency.freeze
        @value = value.freeze
        freeze
      end
    end
  end
end
