$: << 'lib'

require './lib/asrake'
require 'rake/packagetask'

task :default => :build

#FlexSDK::SDK_PATHS << "C:/develop/sdk/flex_sdk_4.6.0.23201"
FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'
#FlexSDK::SDK_PATHS << 'C:\bad\develop\sdk\flex_sdk_4.6.0.23201'

desc "The default build task"
ASRake::SWC.new :build do |build|
	build.target_player = 11.1
	build.source_path << '..\nexuslib\code\projects\reflection\src'
	build.output = '..\nexuslib\code\projects\reflection\bin\test.swc'
	build.statically_link_only_referenced_classes << '..\nexuslib\code\lib\blooddy_crypto_0.3.5\blooddy_crypto.swc'
end