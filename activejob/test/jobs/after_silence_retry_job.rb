# frozen_string_literal: true

require_relative "../support/job_buffer"
require "active_support/core_ext/integer/inflections"

class AfterSilenceRetryJob < ActiveJob::Base
  class UnhandledError < StandardError; end

  class DefaultsError < StandardError; end
  class CustomCatchError < StandardError; end

  class DiscardableError < StandardError; end
  class CustomDiscardableError < StandardError; end

  class SilenceableError < StandardError; end
  class CustomSilenceableError < StandardError; end

  retry_on DefaultsError
  retry_on(CustomCatchError) { |job, error| JobBuffer.add("Dealt with a job that failed to retry in a custom way after #{job.arguments.second} attempts. Message: #{error.message}") }
  retry_on(SilenceableError)
  retry_on(CustomSilenceableError)

  discard_on DiscardableError
  discard_on(CustomDiscardableError) { |_job, error| JobBuffer.add("Dealt with a job that was discarded in a custom way. Message: #{error.message}") }

  after_discard { |_job, error| JobBuffer.add("Ran after_discard for job. Message: #{error.message}") }

  silence_on SilenceableError
  silence_on(CustomSilenceableError) { |_job, error| JobBuffer.add("Dealt with a job that was silenced in a custom way. Message: #{error.message}") }

  after_silence { |_job, error| JobBuffer.add("Ran after_silence for job. Message: #{error.message}") }

  def perform(raising)
    raise raising.constantize
  end
end
