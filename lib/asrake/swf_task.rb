require 'rake/tasklib'

require 'asrake/host'
require 'asrake/basecompilertask'
require 'asrake/flex/mxmlc'

module ASRake
class SWFTask < BaseCompilerTask
	include MxmlcArguments

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil)
		super
	end

	protected

	def build
		run "#{FlexSDK::mxmlc}#{generate_args}" do |line|
			generate_error_message_tips(line)
		end
	end

end
end