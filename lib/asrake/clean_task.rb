require 'rake/tasklib'

module ASRake
class CleanTask < Rake::TaskLib

	def initialize(args)
		desc "Remove package results & build artifacts"
		task :clean do
			FileList.new(File.join(args.output_dir, "*")).exclude(args.output).each { |f| rm_r f rescue nil }
		end

		desc "Remove all build & package results"
		task :clobber => [:clean] do
			FileList.new(File.join(args.output_dir, "*")).each { |f| rm_r f rescue nil }
		end
	end

end
end