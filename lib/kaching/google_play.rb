# frozen_string_literal: true

require 'google/cloud/storage'
require 'csv'
require 'zip'
require 'date'

module Kaching
  # Fetch sales data from Google Play
  module GooglePlay
    class << self
      def configure(credentials_file_path:, bucket_id:)
        @credentials_file_path = credentials_file_path
        @bucket_id = bucket_id
      end

      # @return [Google::Cloud::Storage::Project]
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
      def latest_sales_report_file
        bucket
          .files
          .select { |f| f.name.start_with?('sales/') }
          .max_by(&:created_at)
      end

      # @return [String]
      def latest_sales_report
        file = latest_sales_report_file
        raise("Expected a ZIP file; got #{file.name}") unless file.name.end_with?('.zip')

        zip_data = file.download
        zip_data.rewind
        Zip::File.open_buffer(zip_data) do |zip|
          entry = zip.entries.first
          return entry.get_input_stream(&:read)
        end
      end

      # @return [Array(Date,Integer,Hash<String,Numeric>)]
      def latest_sales_count
        report = latest_sales_report
        info_by_date = {}

        parse_report(report).each do |row|
          date = row[:order_charged_date]
          info = info_by_date[date] ||= [0, Hash.new(0)]
          case row[:financial_status]
          when 'Charged'
            info[0] += 1
            info[1][row[:currency_of_sale]] += row[:charged_amount]
          when 'Refund'
            info[0] -= 1
            info[1][row[:currency_of_sale]] += row[:charged_amount]
          end
        end

        info_by_date.max_by(&:first).flatten
      end

      # @param report [String]
      # @return [CSV]
      def parse_report(str)
        CSV.parse(
          str,
          headers: true,
          converters: %i[numeric date],
          header_converters: :symbol
        )
      end
    end
  end
end
