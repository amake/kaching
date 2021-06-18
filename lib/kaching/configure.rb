# frozen_string_literal: true

require 'json'

module Kaching
  # Configure connection info for stores
  module Configure
    class << self
      def from_json_file(path)
        config = File.open(path, 'r') do |f|
          JSON.parse(f.read, symbolize_names: true)
        end

        AppStore.configure(**config[:app_store])
        GooglePlay.configure(**config[:google_play])
        Currency.configure(**config[:open_exchange_rates])
      end
    end
  end
end
