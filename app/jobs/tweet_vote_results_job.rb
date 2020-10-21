# frozen_string_literal: true

class TweetVoteResultsJob < ApplicationJob
  def perform(kadai, type:)
    max_vote_count = kadai.works.where(type: type).maximum(:votes_count)
    top_works = kadai.works.where(type: type, votes_count: max_vote_count)
    GenronSFFun::TwitterClient.instance.update(<<~TWEET.chomp)
      現時点での第#{kadai.number}回#{type.constantize.model_name.human}の最高得票作は
      #{top_works.map { |work| "#{work.student.name}『#{work.title}』" }.join("\n")}
      で#{max_vote_count}票です！
      #裏SF創作講座
      https://genron-sf-fun.herokuapp.com/kadais/#{kadai.id}
    TWEET
  end
end