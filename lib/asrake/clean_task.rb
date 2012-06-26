require 'rake/tasklib'

module ASRake
class CleanTask < Rake::TaskLib

	attr_accessor :clean_list
	attr_accessor :clobber_list

	def initialize(*args)

		self.clean_list = FileList.new
		self.clobber_list = FileList.new

		args.each do |configArgs|
			clean_list.include(File.join(configArgs.output_dir, "*"))
			clean_list.exclude(configArgs.output)

			clobber_list.include(File.join(configArgs.output_dir, "*"))
		end

		desc "Remove package results & build artifacts"
		task :clean do
			clean_list.each { |f| rm_r f rescue nil }
		end

		desc "Remove all build & package results"
		# adding clean as a dependency in case anything is added to the clean task later
		task :clobber => [:clean] do
			clobber_list.each { |f| rm_r f rescue nil }
		end
	end

end
end