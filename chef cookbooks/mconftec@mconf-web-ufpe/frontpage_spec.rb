require 'spec_helper'
require 'support/feature_helpers'

feature 'Frontpage' do

  context 'visit landing page' do
    before { visit root_path }

    skip { page.should have_content(Site.current.name) } # not for UFPE
    it { page.should have_content(I18n.t('frontpage.show.register.title')) }
    it { page.should have_content(I18n.t('frontpage.show.login.title')) }
  end

end
