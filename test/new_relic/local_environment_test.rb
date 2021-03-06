# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

require File.expand_path(File.join(File.dirname(__FILE__),'..', 'test_helper'))
class NewRelic::LocalEnvironmentTest < Test::Unit::TestCase

  def self.teardown
    # To remove mock server instances from ObjectSpace
    ObjectSpace.garbage_collect
    super
  end
  class MockOptions
    def fetch (*args)
      1000
    end
  end
  MOCK_OPTIONS = MockOptions.new

#  def test_environment
#    e = NewRelic::LocalEnvironment.new
#    assert(nil == e.environment) # working around a bug in 1.9.1
#    assert_match /test/i, e.dispatcher_instance_id
#  end
#  def test_no_webrick
#    Object.const_set :OPTIONS, 'foo'
#    e = NewRelic::LocalEnvironment.new
#    assert(nil == e.environment) # working around a bug in 1.9.1
#    assert_match /test/i, e.dispatcher_instance_id
#    Object.class_eval { remove_const :OPTIONS }
#  end

  def test_passenger
    class << self
      module ::PhusionPassenger
      end
    end
    NewRelic::Agent.reset_config
    e = NewRelic::LocalEnvironment.new
    assert_equal :passenger, e.discovered_dispatcher
    assert_equal :passenger, NewRelic::Agent.config[:dispatcher]
    assert_nil e.dispatcher_instance_id, "dispatcher instance id should be nil: #{e.dispatcher_instance_id}"

    with_config(:app_name => 'myapp') do
      e = NewRelic::LocalEnvironment.new
      assert_equal :passenger, e.discovered_dispatcher
      assert_nil e.dispatcher_instance_id
    end

  ensure
    Object.send(:remove_const, :PhusionPassenger)
  end


  def test_default_port
    e = NewRelic::LocalEnvironment.new
    assert_equal 3000, e.send(:default_port)
    ARGV.push '--port=3121'
    assert_equal '3121', e.send(:default_port)
    ARGV.pop
  end
end
