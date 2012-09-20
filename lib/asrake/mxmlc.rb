require 'asrake/host'
require 'asrake/base_compiler'
require 'asrake/asdoc'

module ASRake
class Mxmlc < BaseCompilerTask

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil)
		super

		# always build until we can properly grab dependencies
		task @name => self.output_dir do
			self.build
			result = c self.output
			result << " (#{File.size(output)} bytes)" unless self.output_is_dir?
			puts result
		end

	end

	def compiler
		FlexSDK::mxmlc
	end

end
end