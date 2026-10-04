ARG ruby_version=3.4
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version


FROM --platform=$TARGETPLATFORM $builder_image AS builder

WORKDIR $APP_HOME
COPY Gemfile* .ruby-version ./
RUN bundle install
COPY . .
# The Git-pinned source gem needs the same locked frontend assets packaged by the published RubyGem.
RUN bash bin/install-pinned-components-assets
RUN rails assets:precompile && rm -fr log
RUN bootsnap precompile --gemfile .


FROM --platform=$TARGETPLATFORM $base_image

ENV GOVUK_APP_NAME=collections
ENV BUNDLE_FROZEN=true

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $BOOTSNAP_CACHE_DIR $BOOTSNAP_CACHE_DIR
COPY --from=builder $APP_HOME .

USER app
CMD ["puma"]
