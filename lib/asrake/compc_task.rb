require 'rake/tasklib'

require 'asrake/host'
require 'asrake/base_compiler_task'
require 'asrake/compc_args'
require 'asrake/asdoc'

module ASRake
class CompcTask < BaseCompilerTask
	include CompcArguments_Module

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil)
		super

		# create directory task for output
		if !output_is_dir?
			directory self.output_dir
			file self.output => self.output_dir
		end
		
		# create file task for output
		file self.output do
			self.build
		end

		# allow setting source_path with '=' instead of '<<'
		self.source_path = [self.source_path] if self.source_path.is_a? String

		# set dependencies on all .as and .mxml files in the source paths
		dependencies = FileList.new
		self.source_path.each do |path|
			path = cf path
			dependencies.include(File.join(path, "*.as"))
			dependencies.include(File.join(path, "*.mxml"))
			dependencies.include(File.join(path, "**", "*.as"))
			dependencies.include(File.join(path, "**", "*.mxml"))
		end
		file(self.output => dependencies) if !dependencies.empty?

		# add output file task as a dependency to the named task created
		task @name => self.output do
			result = c self.output
			result << " (#{File.size(output)} bytes)" unless self.output_is_dir?
			puts result
		end

		if @include_asdoc
			file self.output do
				asdoc = ASRake::Asdoc.new
				asdoc.output = "#{self.output_dir}/.asrake_temp/"
				asdoc.add(self)
				asdoc.keep_xml = true
				asdoc.skip_xsl = true
				asdoc.lenient = true
				asdoc.exclude_dependencies = true
				asdoc.execute do |line|
					# make this silent by swallowing output
				end

				if output_is_dir?
					cp_r File.join(asdoc.output, 'tempdita'), File.join(self.output_dir, 'docs')
				else
					Zip::ZipFile.open(self.output) do |zipfile|
						# remove any existing docs (eg, from -include-libraries linking a swc with asdoc)
						begin
							zipfile.remove('docs')
						rescue
						end
						FileList[File.join(asdoc.output, 'tempdita', '*')].each do |file|
							zipfile.add(File.join('docs', File.basename(file)), file)
						end
					end
				end

				rm_rf asdoc.output, :verbose => false
			end
		end

	end

end
end