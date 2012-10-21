require 'asrake/util'
require 'asrake/base_compiler'
require 'asrake/asdoc'

module ASRake
class Compc < BaseCompiler

	include Rake::DSL
	
	attr_accessor :include_asdoc

	#
	# Create a compc task for the provided swc
	#
	def initialize(swc_file)
		super(swc_file, FlexSDK::compc)
	end

	def execute
		super
		# include asdoc if needed
		if self.include_asdoc
			asdoc = ASRake::Asdoc.new File.join(self.output_dir, ".asrake_temp_#{Time.now.to_i}_#{rand(1000)}")
			asdoc.add(self)
			asdoc.keep_xml = true
			asdoc.skip_xsl = true
			asdoc.lenient = true
			puts "> #{FlexSDK::asdoc}"
			asdoc.execute {|line| puts ">    #{line}"}

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

	def generate_args
		compc = super
		
		#compc << " -include-sources=#{Path::forward source_path.join(',')}" if !source_path.empty?
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