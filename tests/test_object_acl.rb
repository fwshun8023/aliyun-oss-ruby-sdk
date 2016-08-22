require 'minitest/autorun'
require 'yaml'
$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require 'aliyun/oss'
require_relative 'config'

class TestObjectACL < Minitest::Test
  def setup
    AliyunSDK::Common::Logging.set_log_level(Logger::DEBUG)
    client = AliyunSDK::OSS::Client.new(TestConf.creds)
    @bucket = client.get_bucket(TestConf.bucket)

    @prefix = "tests/object_acl/"
  end

  def get_key(k)
    "#{@prefix}#{k}"
  end

  def test_put_object
    key = get_key('put')

    @bucket.put_object(key, acl: AliyunSDK::OSS::ACL::PRIVATE)
    acl = @bucket.get_object_acl(key)

    assert_equal AliyunSDK::OSS::ACL::PRIVATE, acl

    @bucket.put_object(key, acl: AliyunSDK::OSS::ACL::PUBLIC_READ)
    acl = @bucket.get_object_acl(key)

    assert_equal AliyunSDK::OSS::ACL::PUBLIC_READ, acl
  end

  def test_append_object
    key = get_key('append-1')

    @bucket.append_object(key, 0, acl: AliyunSDK::OSS::ACL::PRIVATE)
    acl = @bucket.get_object_acl(key)

    assert_equal AliyunSDK::OSS::ACL::PRIVATE, acl

    key = get_key('append-2')

    @bucket.put_object(key, acl: AliyunSDK::OSS::ACL::PUBLIC_READ)
    acl = @bucket.get_object_acl(key)

    assert_equal AliyunSDK::OSS::ACL::PUBLIC_READ, acl
  end
end
