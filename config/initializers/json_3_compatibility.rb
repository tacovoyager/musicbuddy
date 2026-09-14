# frozen_string_literal: true

# ponytail: json 3.0 removed positional opts hash argument from JSON.parse(source, opts).
# ActiveSupport 8.1 and third-party gems (OmniAuth, OAuth2) pass options as a
# positional Hash argument, causing ArgumentError (given 2, expected 1).
# Upgrade path: Remove this patch when ActiveSupport and ecosystem gems update for json 3.x kwarg-only signature.
module JSON
  class << self
    alias_method :legacy_parse, :parse

    def parse(source, opts = nil, **options)
      if opts.is_a?(Hash)
        legacy_parse(source, **opts.merge(options))
      elsif opts.nil?
        legacy_parse(source, **options)
      else
        legacy_parse(source, opts, **options)
      end
    end
  end
end
