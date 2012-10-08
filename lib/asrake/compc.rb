require 'asrake/util'
require 'asrake/base_compiler'
require 'asrake/asdoc'

module ASRake
class Compc < BaseCompiler

	include ASRake::PathUtils
	include Rake::DSL
	
	attr_accessor :include_asdoc

	#
	# Create a compc task for the provided swc
	#
	def initialize(swc_file)
		super(swc_file, FlexSDK::compc)

		# set dependencies on all .as and .mxml files in the source paths
		dependencies = FileList.new
		self.source_path.each do |path|
			dependencies.include(File.join(cf path, "**/*.as"))
			dependencies.include(File.join(cf path, "**/*.mxml"))
		end
		file(self.output => dependencies) if !dependencies.empty?

		# update build task to include asdoc
		file self.output do
			if self.include_asdoc
				asdoc = ASRake::Asdoc.new File.join(self.output_dir, ".asrake_temp")
				asdoc.add(self)
				asdoc.keep_xml = true
				asdoc.skip_xsl = true
				asdoc.lenient = true
				# capture output in a block to prevent it from going to console
				asdoc.execute { |line| }

				if output_is_dir?
					cp_r "#{asdoc.output}/tempdita", File.join(self.output_dir, "docs")
				else
					Zip::ZipFile.open(self.output) do |zipfile|
						# remove existing docs (eg, from -include-libraries linking a swc with pre-existing docs)
						begin
							zipfile.remove("docs")
						rescue
							#no rescue
						end
						FileList["#{asdoc.output}/tempdita/*"].each do |file|
							zipfile.add("docs/#{File.basename(file)}", file)
						end
					end
				end

				rm_rf asdoc.output, :verbose => false
			end
		end

	end

	def generate_args
		compc = super
		
		#compc << " -include-sources=#{cf source_path.join(',')}" if !source_path.empty?
		self.source_path.each do |path|
			compc << " -include-classes #{ASRake::get_classes(path).join(' ')}"
		end

		return compc
	end

	def merge_in(args)
		super
		self.include_asdoc = args.include_asdoc
	end

end
end