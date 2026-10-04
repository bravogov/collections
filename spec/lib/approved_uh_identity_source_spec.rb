require "spec_helper"
require "digest"

RSpec.describe "Approved shared GOV.UH identity source" do
  let(:components_path) { Gem.loaded_specs.fetch("govuk_publishing_components").full_gem_path }

  it "uses the approved central government arms" do
    source = File.join(components_path, "app/assets/images/govuk_publishing_components/uh_footer_arms.webp")
    expect(Digest::SHA256.file(source).hexdigest).to eq("bd1ff9f66f8cc1d421f65d09ec3a0b53bed34c2f88c3dea1eb2317a358db7804")
  end

  it "uses the approved header crown rather than imported UK artwork" do
    source = File.join(components_path, "app/assets/images/govuk_publishing_components/uh_header_crown.png")
    expect(Digest::SHA256.file(source).hexdigest).to eq("293218916b282a75c89326fab581942fe1f46652a32d122c17d47c9545398675")
  end

  it "renders the GOV.UH wordmark from the native logo component" do
    partial = File.read(File.join(components_path, "app/views/govuk_publishing_components/components/govuk_logo/_govuk_logo.html.erb"))
    expect(partial).to include('aria-label="GOV.UH"')
    expect(partial).not_to include('aria-label="GOV.UK"')
  end

  it "uses GOV.UH public copy in the installed shared locale" do
    locale = File.read(File.join(components_path, "config/locales/en.yml"))
    expect(locale).to include("Cookies on GOV.UH")
    expect(locale).to include("Search GOV.UH")
    expect(locale).to include("Help us improve GOV.UH")
  end

  it "does not expose inherited GOV.UK machine-readable or survey identity" do
    metadata = File.read(File.join(components_path, "app/views/govuk_publishing_components/components/_machine_readable_metadata.html.erb"))
    survey = File.read(File.join(components_path, "app/views/govuk_publishing_components/components/feedback/_survey_signup_form.html.erb"))
    expect(metadata).to include('content="GOV.UH"')
    expect(metadata).not_to include('content="GOV.UK"')
    expect(survey).not_to include("smartsurvey.co.uk")
    expect(survey).to include('href="/contact/"')
  end

end
