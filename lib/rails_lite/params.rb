require 'uri'
require 'active_support'

class Params
  attr_reader :params

  def initialize(req, route_params = {})
    if req.is_a?(WEBrick::HTTPRequest)
      @permitted_keys = []
      @params = route_params
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
    end
  end

  def [](key)
    self.params[key]
  end

  def permit(*keys)
    keys.each { |key| @permitted_keys << key }
  end

  def require(key)
    raise Params::AttributeNotFoundError if !@params.keys.include?(key)
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    self.params.to_json
  end

  class AttributeNotFoundError < ArgumentError; end;

  private

  def parse_www_encoded_form(www_encoded_form)
    params_array = URI::decode_www_form(www_encoded_form).map do |param|
      value = param.last

      parse_key(param.first).reverse.inject(value) { |a, n| { n => a } }
    end

    hash = {}
    params_array.each do |param|
      hash.deep_merge!(param)
    end
    hash
  end

  def parse_key(key)
    parsed_key = key.split(/\]\[|\[|\]/)
  end
end
