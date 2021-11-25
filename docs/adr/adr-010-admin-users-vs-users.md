### ADR - 010: Admin Users vs Users

#### Why do we have 2 User classes, AdminUser and User?

This is modelling a real life split. `AdminUsers` are internal DLUHC users or helpdesk employees. While `Users` are external users working at data providing organisations. So local authority/housing association's "admin" users, i.e. Data Co-ordinators are a type of the User class. They have the ability to add or remove other users to or from their organisation, and to update their organisation details etc, but only through the designed UI. They do not get direct access to ActiveAdmin.

AdminUsers on the other hand get direct access to ActiveAdmin. From there they can download entire datasets (via CSV, XML, JSON), view any log from any organisation, and add or remove users of any type including other Admin users. This means TDA will likely also require more stringent authentication for them using MFA (which users will likely not require). So the class split also helps there.

A potential downside to this approach is that it does not currently allow for `AdminUsers` to sign into the application UI itself with their Admin credentials. However, we need to see if there's an actual use case for this and what it would be (since they aren't part of an organisation to be uploading data for, but could add or amend data or user or org details through ActiveAdmin anyway). If there is a strong use case for it this could be work around by either: providing them with two sets of credentials, or modifying the `authenticate_user` method to also check `AdminUser` credentials.
