# frozen_string_literal: true

module LoginSystemHelper
  def log_in(user)
    OmniAuth.config.add_mock(
      :twitter,
      {
        uid: user.twitter_id,
        info: {
          nickname: user.twitter_screen_name,
          name: user.student.name,
          image: user.image_url,
          urls: {
            'Twitter': user.student.url,
          },
        },
        credentials: {
          token: 'token',
          secret: 'secret',
        },
      },
    )

    visit root_path
    click_link 'Twitter でログイン', match: :first
  end
end
