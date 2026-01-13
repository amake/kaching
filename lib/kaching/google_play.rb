# frozen_string_literal: true

require 'google/cloud/storage'
require 'csv'
require 'zip'

module Kaching
  # Fetch sales data from Google Play
  module GooglePlay
    class << self
      def configure(credentials_file_path:, bucket_id:)
        @credentials_file_path = credentials_file_path
        @bucket_id = bucket_id
      end

      # @return [Google::Cloud::Storage]
      def client
        Google::Cloud::Storage.new(
          credentials: @credentials_file_path,
          scope: 'https://www.googleapis.com/auth/devstorage.read_only'
        )
      end

      # @return [Google::Cloud::Storage::Bucket]
      def bucket
        client.bucket(@bucket_id)
      end

      # @return [Google::Cloud::Storage::File]
      def latest_store_data_file
        bucket
          .files
          .select { |f| f.name.start_with?('sales/') }
          .max_by(&:created_at)
      end

      # @return [String]
      def latest_store_data
        file = latest_store_data_file
        raise("Expected a ZIP file; got #{file.name}") unless file.name.end_with?('.zip')

        zip_data = file.download
        zip_data.rewind
        Zip::File.open_buffer(zip_data) do |zip|
          entry = zip.entries.first
          return entry.get_input_stream(&:read)
        end
      end

      # @return [Model::Report]
      def latest_sales_report
        data = latest_store_data

        transactions_by_date =
          parse_data(data).each_with_object({}) do |row, acc|
            date = row[:order_charged_date]
            transactions = acc[date] ||= []
            case row[:financial_status]
            when 'Charged'
              transactions << Model::Transaction.new(
                type: :purchase,
                units: 1,
                currency: row[:currency_of_sale],
                value: row[:charged_amount].abs
              )
            when 'Refund'
              transactions << Model::Transaction.new(
                type: :purchase,
                units: -1,
                currency: row[:currency_of_sale],
                value: row[:charged_amount].abs
              )
            end
          end

        date, transactions = transactions_by_date.max_by(&:first)
        Model::Report.new(date: date, transactions: transactions)
      end

      # @param data [String]
      # @return [Array<Array<String,undefined>>]
      def parse_data(data)
        CSV.parse(
          data,
          headers: true,
          converters: [:numeric, :date, ->(v) { convert_thousands_separated_number(v) }],
          header_converters: :symbol
        )
      end

      # @param value [String]
      # @return [Numeric]
      def convert_thousands_separated_number(value)
        normalized = value.delete(',')
        Integer(normalized)
      rescue ArgumentError
        begin
          Float(normalized)
        rescue ArgumentError
          value
        end
      end
    end
  end
end
