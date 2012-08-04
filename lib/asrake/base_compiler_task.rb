require 'rake/tasklib'
require 'asrake/base_compiler_args'

module ASRake
class BaseCompilerTask < Rake::TaskLib
	include BaseCompilerArguments_Module

	def initialize(name, args)
		super(args)

		@name = name
		
		# create named task first so it gets the desc if one is added
		Rake::Task.define_task @name

		# if the task name is a hash (ie, has dependencies defined) make sure we pull out the task name from it
		@name, _ = name.first if name.is_a? Hash

	end

end
end