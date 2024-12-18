# frozen_string_literal: true

require 'open_exchange_rates'

module Kaching
  # Utilities for converting currency
  module Currency
    class << self
      # @param app_id [String]
      def configure(app_id:)
        OpenExchangeRates.configure do |config|
          config.app_id = app_id
        end
        @fx = OpenExchangeRates::Rates.new
        @cache = Cache.new(name: 'fx')
      end

      # @param from [String]
      # @param to [String]
      # @param amount [Numeric]
      # @return [Numeric]
      def convert(from:, to:, amount:)
        return amount if from.casecmp(to).zero?
        return 0 if amount.zero?

        @fx.round(amount * exchange_rate(from: from, to: to))
      end

      # @param from [String]
      # @param to [String]
      # @return [Numeric]
      def exchange_rate(from:, to:)
        return 1 if from.casecmp(to).zero?

        key = "#{from}_#{to}"
        @cache.get(key) || begin
          rate = @fx.exchange_rate(from: from, to: to)
          @cache.set(key, rate, expires: DateTime.now.next_day.to_time.to_i)
          rate
        end
      end
    end
  end
end
