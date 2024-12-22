# frozen_string_literal: true

require 'json'

module Kaching
  # Cache data to prevent unnecessary API calls
  class Cache
    # @param name [String]
    def initialize(name:)
      @file = "cache/#{name}.json"
      @data = load_data
    end

    # @param key [String,Symbol]
    # @return [Object,nil]
    def get(key)
      key = key.to_sym
      # @type [Integer,nil]
      expires = @data[key]&.[](:expires)
      return nil if expires && Time.now.to_i > expires

      @data[key]&.[](:value)
    end

    # @param key [String,Symbol]
    # @param value [Object]
    # @param expires [Integer,nil] timestamp
    def set(key, value, expires: nil)
      @data[key.to_sym] = { value: value, expires: expires }
      persist
    end

    private

    def load_data
      File.exist?(@file) ? JSON.parse(File.read(@file), symbolize_names: true) : {}
    end

    def persist
      FileUtils.mkdir_p(File.dirname(@file))
      File.write(@file, JSON.pretty_generate(@data))
    end
  end
end
