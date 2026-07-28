# frozen_string_literal: true

# Compatibility patch for devise_two_factor_authentication 3.0.0 on Rails 8+.
#
# The gem's route mapper passes the non-standard :resend_code action into
# `resource ... only: [...]`. Rails 8 tightened `resource`/`resources` to raise
# an ArgumentError when :only/:except contain anything outside the standard REST
# actions. So, we redefine the mapper method here to drop it now we are on Rails 8+
module ActionDispatch::Routing
  class Mapper
  protected

    def devise_two_factor_authentication(mapping, controllers)
      resource :two_factor_authentication,
               only: %i[show update],
               path: mapping.path_names[:two_factor_authentication],
               controller: controllers[:two_factor_authentication] do
        collection { get resend_code_path(mapping), as: "resend_code" }
      end
    end
  end
end
