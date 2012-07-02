require 'rake/tasklib'

require 'asrake/host'
require 'asrake/base_task'
require 'asrake/mxmlc_args'

module ASRake
class MxmlcTask < BaseCompilerTask
	include MxmlcArguments_Module

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil)
		super

		# create directory task for output
		directory self.output_dir

		# always build until we can properly grab dependencies
		task @name => self.output_dir do
			self.build
			result = c self.output
			result << " (#{File.size(output)} bytes)" unless self.output_is_dir?
			puts result
		end

	end

	protected

	def build
		run "#{FlexSDK::mxmlc}#{generate_args}" do |line|
			generate_error_message_tips(line)
		end
	end

end
end