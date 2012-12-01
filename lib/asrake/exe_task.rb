require 'asrake/util'
require 'rake/file_task'

module ASRake
class ExeTask < Rake::FileTask

	attr_accessor :pre_invoke
	attr_accessor :post_invoke

	def initialize(task_name, app)
		super
	end

	def invoke_with_call_chain(task_args, invocation_chain)
		pre_invoke.call() if pre_invoke != nil
		super
		post_invoke.call() if post_invoke != nil
    end
end
end