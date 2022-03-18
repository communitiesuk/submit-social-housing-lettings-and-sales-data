// Load ActiveAdmin’s styles into Webpacker.
// See `active_admin.scss` for customisation.
import "../styles/active_admin";

import Rails from '@rails/ujs'
import * as ActiveStorage from '@rails/activestorage'
import '@rails/actiontext'
import 'trix'
import '@cmdbrew/adminterface'
import 'chartkick/chart.js'

ActiveStorage.start()
Rails.start()
