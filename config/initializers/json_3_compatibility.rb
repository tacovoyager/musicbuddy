# frozen_string_literal: true

# ponytail: json 3.0 removed positional opts hash argument from JSON.parse(source, opts)
# and raises ArgumentError on legacy options like :escape or :quirks_mode.
# ActiveSupport 8.1, SolidQueue, and third-party gems (OmniAuth, OAuth2) pass positional hashes
# and legacy options to JSON.parse.
# Upgrade path: Remove this patch when ActiveSupport and ecosystem gems update for json 3.x.
module JSON
  class << self
    alias_method :legacy_parse, :parse

    def parse(source, opts = nil, **options)
      merged = (opts.is_a?(Hash) ? opts.merge(options) : options).dup
      merged.delete(:escape)
      merged.delete(:quirks_mode)

      legacy_parse(source, **merged)
    end
  end
end
