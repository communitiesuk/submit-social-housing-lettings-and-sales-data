class LocalAuthorityLink < ApplicationRecord
  belongs_to :local_authority, class_name: "LocalAuthority"
  belongs_to :linked_local_authority, class_name: "LocalAuthority"
end
