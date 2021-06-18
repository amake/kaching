# frozen_string_literal: true

require_relative 'kaching/version'
require_relative 'kaching/configure'
require_relative 'kaching/app_store'
require_relative 'kaching/google_play'
require_relative 'kaching/currency'

module Kaching
  class Error < StandardError; end
  # Your code goes here...
end
