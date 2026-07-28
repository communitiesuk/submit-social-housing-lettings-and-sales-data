# frozen_string_literal: true

# Compatibility patch for devise_two_factor_authentication 3.0.0 on Rails 8.1+.
#
# The gem's route mapper passes the non-standard :resend_code action into
# `resource ... only: [...]`. Rails 8.1 tightened `resource`/`resources` to raise
# an ArgumentError when :only/:except contain anything outside the standard REST
# actions, so route drawing blows up before the app can boot.
#
# The `resend_code` route is actually created by the `collection { ... }` block
# inside the resource, so listing :resend_code in :only was always a no-op.
# We redefine the mapper method to drop it, leaving behaviour identical.
#
# Remove this file if the gem publishes a Rails 8.1-compatible release.
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
