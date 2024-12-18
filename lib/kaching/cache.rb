# frozen_string_literal: true

require 'json'

module Kaching
  # Cache data to prevent unnecessary API calls
  class Cache
    # @param name [String]
    def initialize(name:)
      FileUtils.mkdir_p('cache')
      @file = "cache/#{name}.json"
      @data = File.exist?(@file) ? JSON.parse(File.read(@file)) : {}
    end

    # @param key [String]
    # @return [Object,nil]
    def get(key)
      # @type [Integer,nil]
      expires = @data[key]&.[](:expires)
      return nil if expires && Time.now.to_i > expires

      @data[key]&.[](:value)
    end

    # @param key [String]
    # @param value [Object]
    # @param expires [Integer,nil] timestamp
    def set(key, value, expires: nil)
      @data[key] = { value: value, expires: expires }
      File.write(@file, JSON.pretty_generate(@data))
    end
  end
end
