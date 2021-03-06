# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    student factory: :student, genron_sf_id: nil
    sequence(:twitter_id)
    image_url { "https://example.com/profile_images/#{twitter_id}.jpeg" }
    sequence(:twitter_screen_name) { |n| "twitter_screen_name#{n}" }
    last_logged_in_at { Time.zone.now }
  end
end
