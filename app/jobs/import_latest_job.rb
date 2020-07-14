# frozen_string_literal: true

class ImportLatestJob < ApplicationJob
  def perform(tweet: false)
    start_time = Time.zone.now

    ImportKadaisJob.perform_now(year: Kadai::LATEST_YEAR)
    ImportWorksJob.perform_now(kadais: Kadai.newest3)

    return unless tweet

    Kadai
      .where(year: Kadai::LATEST_YEAR, created_at: start_time..)
      .each { |kadai| tweet(kadai_tweet_text(kadai)) }

    Kougai
      .includes(student: :user)
      .joins(:kadai).merge(Kadai.newest3)
      .where(created_at: start_time..).where.not(genron_sf_id: nil)
      .each { |kougai| tweet(work_tweet_text(kougai)) }

    Jissaku
      .includes(student: :user)
      .joins(:kadai).merge(Kadai.newest3)
      .where(created_at: start_time..).where.not(genron_sf_id: nil)
      .each { |jissaku| tweet(work_tweet_text(jissaku)) }
  end

  private

  def kadai_tweet_text(kadai)
    lines = []
    lines << "【課題】 第#{kadai.number}回「#{kadai.title}」"
    lines << "課題提示: #{kadai.author}" if kadai.author.present?
    lines << "梗概締切: #{I18n.localize(kadai.kougai_deadline, format: :long)}" if kadai.kougai_deadline
    lines << "実作締切: #{I18n.localize(kadai.jissaku_deadline, format: :long)}" if kadai.jissaku_deadline
    lines << '#SF創作講座 #裏SF創作講座'
    lines << kadai.genron_sf_url
    lines << "https://genron-sf-fun.herokuapp.com/kadais/#{kadai.id}"
    lines.join("\n")
  end

  def work_tweet_text(work)
    lines = []
    lines << if work.student.user
               "【#{work.class.model_name.human}】#{work.student.name} #{work.student.user.twitter_screen_name} 『#{work.title}』"
             else
               "【#{work.class.model_name.human}】#{work.student.name}『#{work.title}』"
             end
    lines << '#SF創作講座'
    lines << work.url
    lines.join("\n")
  end

  def tweet(text)
    GenronSFFun::TwitterClient.instance.update(text)
  rescue Twitter::Error => e
    Raven.capture_exception(e, extra: { tweet: text })
  end
end