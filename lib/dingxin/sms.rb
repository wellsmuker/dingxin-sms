require "dingxin/sms/version"
require "openssl"
require "typhoeus"
require "erb"

include ERB::Util

module Dingxin
  module Sms
    class Configuration
      attr_accessor :app_code

      def initialize
        @app_code = ''
      end
    end # class Configuration

    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def send(mobile, tpl_id, param)
        Typhoeus.post(get_url({
          'mobile' => mobile,
          'tpl_id' => tpl_id,
          'param' => param
          }),
          headers: { "Authorization" => "APPCODE #{configuration.app_code}" })
      end

      # curl -i -X POST 'http://dingxin2.market.alicloudapi.com/dx/longSendSms?mobile=159XXXX9999&param=param&tpl_id=TP1802095'  -H 'Authorization:APPCODE 你自己的AppCode'
      def long_send(mobile, tpl_id, param)
        Typhoeus.post(get_long_url({
          'mobile' => mobile,
          'tpl_id' => tpl_id,
          'param' => param
          }),
          headers: { "Authorization" => "APPCODE #{configuration.app_code}" })
      end

      def get_url(params)
        coded_params = canonicalized_query_string(params)
        url = 'http://dingxin.market.alicloudapi.com/dx/sendSms?' + coded_params
      end

      def get_long_url(params)
        coded_params = canonicalized_query_string(params)
        url = 'http://dingxin2.market.alicloudapi.com/dx/longSendSms?' + coded_params
      end

      # 对字符串进行 PERCENT 编码
      # https://apidock.com/ruby/ERB/Util/url_encode
      def encode(input)
        output = url_encode(input)
      end
      
      # 规范化参数
      def canonicalized_query_string(params)
        cqstring = ''
        params.sort_by{|key, val| key}.each do |key, value|
          if cqstring.empty?
            cqstring += "#{encode(key)}=#{encode(value)}"
          else
            cqstring += "&#{encode(key)}=#{encode(value)}"
          end
        end
        cqstring
      end

    end # class << self
  end # module Sms
end # module Dingxin
