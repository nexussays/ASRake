$: << 'lib'

require './lib/asrake'

task :default => 'swc:build'

FlexSDK::SDK_PATHS << "C:/develop/sdk/flex_sdk_4.6.0.23201"
#FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'

ASRake::SWC.new do |t|
	t.source_path = 'C:\Users\nexus\Development\Projects\Personal\nexuslib\code\projects\reflection\src'
	t.output = 'C:\Users\nexus\Development\Projects\Personal\nexuslib\code\projects\reflection\bin\test.swc\\'
	t.library_path << 'C:\Users\nexus\Development\Projects\Personal\nexuslib\code\lib\blooddy_crypto_0.3.5\blooddy_crypto.swc'
end