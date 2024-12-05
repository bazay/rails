# frozen_string_literal: true

class RaisingJob < ActiveJob::Base
  MyError = Class.new(StandardError)
  SilencedError = Class.new(StandardError)

  retry_on(MyError, SilencedError, attempts: 2)

  silence_on(SilencedError)

  def perform(error = "RaisingJob::MyError")
    raise error.constantize
  end
end
