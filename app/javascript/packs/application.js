import "bootstrap"
import "../../assets/stylesheets/application.scss"
import "../../../node_modules/jquery/dist/jquery"

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"


Rails.start()
Turbolinks.start()
ActiveStorage.start()
