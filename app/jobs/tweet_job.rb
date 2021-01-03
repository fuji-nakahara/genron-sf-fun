# frozen_string_literal: true

class TweetJob < ApplicationJob
  def perform(status)
    GenronSFFun::TwitterClient.instance.update(status)
  rescue Twitter::Error => e
    Sentry.capture_exception(e, extra: { tweet: status })
  end
end
