module Admin
  module PaperTrail
    extend ActiveSupport::Concern

    included do
      before_action :set_paper_trail_whodunnit
    end

  protected

    def user_for_paper_trail
      current_admin_user
    end
  end
end
