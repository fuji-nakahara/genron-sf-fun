# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TweetImportedJob, type: :job do
  describe '#perform' do
    let(:kadai) do
      create(
        :kadai,
        term: create(:term, year: 2019),
        round: 1,
        title: '「100年後の未来」の物語を書いてください',
        author: '大森望',
        kougai_deadline: '2019-06-13'.to_date,
        jissaku_deadline: '2019-07-11'.to_date,
        tweet_url: nil,
      )
    end
    let!(:kougai) do
      create(
        :kougai,
        kadai: kadai,
        student: student,
        title: 'コウガイ',
        url: 'http://example.com/k',
        genron_sf_id: 1,
        tweet_url: nil,
      )
    end
    let!(:jissaku) do
      create(
        :jissaku,
        kadai: kadai,
        student: student,
        title: 'ジッサク',
        url: 'http://example.com/j',
        genron_sf_id: 2,
        tweet_url: nil,
      )
    end
    let(:student) { create(:student, name: 'フジ・ナカハラ') }

    let(:twitter_client) { instance_double(GenronSFFun::TwitterClient) }

    before do
      allow(GenronSFFun::TwitterClient).to receive(:instance).and_return(twitter_client)
      allow(twitter_client).to receive(:update).and_return(
        instance_double(Twitter::Tweet, url: 'https://twitter.com/genron_sf_fun/status/1234567890123456789'),
      )
    end

    it 'tweets new kadais, kougais and jissakus' do
      described_class.perform_now

      expect(twitter_client).to have_received(:update).with(<<~KADAI_TWEEET.chomp)
        【課題】 第1回「「100年後の未来」の物語を書いてください」
        課題提示: 大森望
        梗概締切: 2019年6月13日(木)
        実作締切: 2019年7月11日(木)
        #SF創作講座 #裏SF創作講座
        https://school.genron.co.jp/works/sf/2019/subjects/1/
        https://genron-sf-fun.herokuapp.com/2019/1
      KADAI_TWEEET
      expect(twitter_client).to have_received(:update).with(<<~KOUGAI_TWEEET.chomp)
        【梗概】フジ・ナカハラ『コウガイ』
        #SF創作講座
        http://example.com/k
      KOUGAI_TWEEET
      expect(twitter_client).to have_received(:update).with(<<~JISSAKU_TWEEET.chomp)
        【実作】フジ・ナカハラ『ジッサク』
        #SF創作講座
        http://example.com/j
      JISSAKU_TWEEET
      expect(kadai.reload.tweet_url).not_to be_nil
      expect(kougai.reload.tweet_url).not_to be_nil
      expect(jissaku.reload.tweet_url).not_to be_nil
    end
  end
end
