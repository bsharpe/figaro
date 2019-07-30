module Figaro
  module ENV
    extend self

    def respond_to?(method, *)
      key, punctuation = extract_key_from_method(method)

      case punctuation
      when "!"
        has_key?(key) || super
      when "?", nil
        true
      else
        super
      end
    end

    private

    def method_missing(method, *)
      key, punctuation = extract_key_from_method(method)

      case punctuation
      when "!"
        send(key) || raise(MissingKey.new(key))
      when "?"
        !!send(key)
      when nil
        get_value(key)
      else
        super
      end
    end

    def extract_key_from_method(method)
      method.to_s.upcase.match(/^(.+?)([!?=])?$/).captures
    end

    def has_key?(key)
      ::ENV.has_key?(key)
    end

    def get_value(key)
      ::ENV[key] || ::ENV[key.downcase]
    end
  end
end
