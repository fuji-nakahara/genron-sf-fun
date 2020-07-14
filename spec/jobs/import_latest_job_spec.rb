# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportLatestJob, type: :job do
  describe '#perform' do
    let(:kadai) do
      create(
        :kadai,
        year: Kadai::LATEST_YEAR,
        number: 1,
        title: '「100年後の未来」の物語を書いてください',
        author: '大森望',
        kougai_deadline: '2020-07-17'.to_date,
        jissaku_deadline: '2020-08-28'.to_date,
      )
    end
    let(:kougai) do
      create(:kougai, kadai: kadai, student: student, title: 'コウガイ', url: 'http://example.com/k', genron_sf_id: 1)
    end
    let(:jissaku) do
      create(:jissaku, kadai: kadai, student: student, title: 'ジッサク', url: 'http://example.com/j', genron_sf_id: 2)
    end
    let(:student) { create(:student, name: 'フジ・ナカハラ') }

    let(:twitter_client) { instance_double(GenronSFFun::TwitterClient) }

    before do
      allow(ImportKadaisJob).to receive(:perform_now) { kadai }
      allow(ImportWorksJob).to receive(:perform_now) do
        kougai
        jissaku
      end
      allow(GenronSFFun::TwitterClient).to receive(:instance).and_return(twitter_client)
      allow(twitter_client).to receive(:update)
    end

    it 'tweets new kadais, kougais and jissakus' do
      described_class.perform_now(tweet: true)

      expect(twitter_client).to have_received(:update).with(<<~KADAI_TWEEET.chomp)
        【課題】 第1回「「100年後の未来」の物語を書いてください」
        課題提示: 大森望
        梗概締切: 2020年7月17日(金)
        実作締切: 2020年8月28日(金)
        #SF創作講座 #裏SF創作講座
        https://school.genron.co.jp/works/sf/2019/subjects/1/
        https://genron-sf-fun.herokuapp.com/kadais/#{kadai.id}
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
    end
  end
end