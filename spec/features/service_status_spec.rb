require 'capybara_helper'

describe 'viewing service status' do
  let(:user) { User.find_or_create_by(name: 'test user', email: 'test@example.justice.gov.uk') }
  let(:service) do
    Service.create!(name: 'ABC Service', git_repo_url: 'https://github.com/some-org/some-repo.git',
                    created_by_user: user)
  end
  before do
    login_as!(user)
  end

  describe 'no service status checks' do
    context 'with no completed deployments' do
      before do
        visit "/services/#{service.slug}"
      end
      it 'does not show a status' do
        expect(page).not_to have_selector('span.status')
        expect(page).to have_selector('span', text: I18n.t('services.environment.no_deployment'))
      end
      it 'does not show a `Check now` button' do
        expect(page).not_to have_button(I18n.t('services.environment.check_now'))
      end
    end
    context 'with completed deployments' do
      before do
        completed_deployment
        visit "/services/#{service.slug}"
      end
      it 'does not show a status' do
        expect(page).not_to have_selector('span.status')
        expect(page).to have_selector('span', text: I18n.t('services.environment.no_deployment'))
      end

      it 'does show a `Check now` button' do
        expect(page).to have_button(I18n.t('services.environment.check_now'))
      end
    end
  end

  describe 'service status checks' do
    context 'with no deployments' do
      before do
        ServiceStatusCheck.create!(environment_slug: 'dev', status: 404, time_taken: 30.0,
                                   timestamp: Time.new, created_at: Time.new, updated_at: Time.new,
                                   url: 'url.test', service: service)
        visit "/services/#{service.slug}"
      end
      it 'does show a status' do
        expect(page).to have_selector('span.status')
      end
      it 'does not show a `Check now` button' do
        expect(page).not_to have_button(I18n.t('services.environment.check_now'))
      end
    end
    context 'with completed deployments' do
      before do
        ServiceStatusCheck.create!(environment_slug: 'dev', status: 200, time_taken: 30.0,
                                   timestamp: Time.new - (60 * 60 )* 24,
                                   created_at: Time.new - (60 * 60 )* 24,
                                   updated_at: Time.new - (60 * 60 )* 24,
                                   url: 'url.test', service: service)
      end
      before do
        completed_deployment
        visit "/services/#{service.slug}"
      end
      it 'does show a status' do
        expect(page).to have_selector('span.status')
      end

      it 'does show a `Check now` button' do
        expect(page).to have_button(I18n.t('services.environment.check_now'))
      end
    end
  end

  def completed_deployment
    ServiceDeployment.create!(commit_sha: 'f7735e5',
                              environment_slug: 'dev',
                              created_at: Time.new - 30,
                              updated_at: Time.new,
                              created_by_user: user,
                              service: service,
                              completed_at: Time.new,
                              status: 'completed',
                              json_sub_dir: '')
  end
end
