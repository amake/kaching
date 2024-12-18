# frozen_string_literal: true

require_relative 'kaching/version'
require_relative 'kaching/configure'
require_relative 'kaching/model'
require_relative 'kaching/app_store'
require_relative 'kaching/google_play'
require_relative 'kaching/currency'
require_relative 'kaching/cache'

module Kaching
  class DataUnavailableError < StandardError; end
end
