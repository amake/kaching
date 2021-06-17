# frozen_string_literal: true

require 'app_store_connect'
require 'csv'
require 'date'

module Kaching
  # Fetch sales data from Apple App Store
  module AppStore
    class << self
      def configure(issuer_id:, key_id:, auth_key_file_path:, vendor_number:)
        AppStoreConnect.config = {
          issuer_id: issuer_id,
          key_id: key_id,
          private_key: File.open(auth_key_file_path, 'r', &:read)
        }
        @vendor_number = vendor_number
      end

      # @return [AppStoreConnect::Client]
      def client
        AppStoreConnect::Client.new
      end

      # @param date [Date]
      # @return [String]
      def sales_report(date:)
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
      def latest_sales_report
        date = Date.today
        7.times do
          report = sales_report(date: date)
          # Result is a String on success, or a Hash on error (no data available
          # for that day)
          return [date, report] if report.is_a?(String)

          date = date.prev_day
        end
      end

      # @return [Date,Integer]
      def latest_sales_count
        date, report = latest_sales_report
        count = 0
        parse_report(report).each do |row|
          count += row[:units] if row[:product_type_identifier] == '1F'
        end
        [date, count]
      end

      # @param report [String]
      # @return [CSV]
      def parse_report(str)
        CSV.parse(
          str,
          col_sep: "\t",
          headers: true,
          converters: :numeric,
          header_converters: :symbol
        )
      end
    end
  end
end
