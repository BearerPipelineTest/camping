require 'test_helper'
require 'camping'

Camping.goes :Packing

module Camping
  module Gear

    # Basically copied from Cuba, will probably modify later.
    module CSRF

      # Package Class Methods
      module ClassMethods
        # define class methods
        def secret_token
          @_secret_token ||= SecureRandom.base64(32)
        end

        def erase_token
          @_secret_token = nil
        end

        def set_secret(secret)
          @_secret_token = secret
        end
      end

      # Run a setup routine with this Gear.
      def self.setup(app, *a, &block)
        @app = app
        @app.set :secret_token, "top_secret_code"
      end

      # Adds an instance method csrf
      def csrf
        @csrf ||= Camping::Gear::CSRF::Helper.new(@state, @request)
      end

      class Helper
        attr_accessor :req
        attr_accessor :state

        def initialize(state, request)
          @state = state
          @req = request
        end
      end
    end
  end
end

module Packing
    pack Camping::Gear::CSRF
end

class Packing::Test < TestCase

  def test_gear_packed
    list = Packing::G
    assert (list.length == 1), "Gear was not packed! Gear: #{list.length}"
  end

  def test_right_gear_packed
    csrf_gear = Packing::G[0].to_s
    assert (csrf_gear == "Camping::Gear::CSRF"), "The correct Gear was not packed! Gear: #{csrf_gear}"
  end

  def test_instance_methods_packed
    im = Packing.instance_methods.map(&:to_s)
    assert (im.include? "csrf"), "Gear instance methods were not included: #{im}"
  end

  def test_class_methods_packed
    [:secret_token, :erase_token, :set_secret].each { |sym|
      assert (Packing.methods.include? sym), "Gear class methods were not packed, missing #{sym.to_s}."
    }
  end

  def test_setup_callback
    secret = Packing.options[:secret_token]
    assert (secret == "top_secret_code"), "Gear setup callback failed: \"#{secret}\" should be \"top_secret_code\"."
  end

end
