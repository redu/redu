# -*- encoding : utf-8 -*-
module SessionsHelper
  def try_openredu_text
    return 'Experimentar o Openredu' if REQUIRE_ACCOUNT_ACTIVATION

    'Começar'
  end
end
