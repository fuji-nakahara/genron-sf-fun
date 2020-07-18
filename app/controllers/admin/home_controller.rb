# frozen_string_literal: true

module Admin
  class HomeController < ApplicationController
    include AdminRequired

    def show
      @users = User.all.reverse_order
      @genron_sf_student_ids = Student.left_joins(:user).where(users: { id: nil }).pluck(:genron_sf_id).compact
      @twitter_screen_names = User.joins(:student).merge(Student.where(genron_sf_id: nil)).pluck(:twitter_screen_name)
    end
  end
end
