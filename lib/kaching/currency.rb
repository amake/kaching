# frozen_string_literal: true

require 'open_exchange_rates'

module Kaching
  # Utilities for converting currency
  module Currency
    class << self
      def configure(app_id:)
        OpenExchangeRates.configure do |config|
          config.app_id = app_id
        end
        @fx = OpenExchangeRates::Rates.new
      end

      # @param from [String]
      # @param to [String]
      # @param amount [Numeric]
      # @return [Numeric]
      def convert(from:, to:, amount:)
        return amount if from.casecmp(to).zero?

        @fx.convert(amount, from: from, to: to)
      end
    end
  end
end
