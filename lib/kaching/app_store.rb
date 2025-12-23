# frozen_string_literal: true

require 'app_store_connect'
require 'csv'

module Kaching
  # Fetch sales data from Apple App Store
  module AppStore
    class << self
      def configure(issuer_id:, key_id:, auth_key_file_path:, vendor_number:)
        AppStoreConnect.config = {
          issuer_id: issuer_id,
          key_id: key_id,
          private_key: File.read(auth_key_file_path)
        }
        @vendor_number = vendor_number
      end

      # @return [AppStoreConnect::Client]
      def client
        AppStoreConnect::Client.new
      end

      # @param date [Date]
      # @return [String]
      def store_data(date:)
        client.sales_reports(
          filter: {
            report_type: 'SALES',
            frequency: 'DAILY',
            report_sub_type: 'SUMMARY',
            vendor_number: @vendor_number.to_s,
            # Date#to_s is guaranteed to be YYYY-MM-DD
            report_date: date.to_s
          }
        )
      end

      # @return [Array(Date,String)]
      def latest_store_data
        date = Date.today
        7.times do
          report = store_data(date: date)
          # Result is a String on success, or a Hash on error (no data available
          # for that day)
          return [date, report] if report.is_a?(String)

          warn(report)

          date = date.prev_day
        end

        raise(DataUnavailableError)
      end

      # @return [Model::Report]
      def latest_sales_report
        date, data = latest_store_data
        transactions = parse_data(data).each_with_object([]) do |row, acc|
          next unless row[:product_type_identifier] == '1F'

          acc << Model::Transaction.new(
            units: row[:units],
            currency: row[:customer_currency],
            value: row[:developer_proceeds].abs
          )
        end

        Model::Report.new(date: date, transactions: transactions)
      end

      # @param data [String]
      # @return [Array<Array<String,undefined>>]
      def parse_data(data)
        CSV.parse(
          data,
          col_sep: "\t",
          headers: true,
          converters: :numeric,
          header_converters: :symbol
        )
      end
    end
  end
end
