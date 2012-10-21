require 'asrake/util'
require 'asrake/base_task'
require 'nokogiri'

module ASRake
class Adt < BaseTask

	include Rake::DSL
	
	# http://help.adobe.com/en_US/air/build/WS5b3ccc516d4fbf351e63e3d118666ade46-7ff1.html
	attr_accessor :application_descriptor

	#
	# The path to the keystore file for file-based store types.
	#
	attr_accessor :keystore
	# 
	# The alias of a key in the keystore. Specifying an alias is not necessary when a keystore only contains
	# a single certificate. If no alias is specified, ADT uses the first key in the keystore.
	#
	attr_accessor :alias
	attr_accessor :storetype
	attr_accessor :storepass
	attr_accessor :keystore_name
	#
	# Specifies the URL of an RFC3161-compliant timestamp server to time-stamp the digital signature.
	# If no URL is specified, a default time-stamp server provided by Geotrust is used. When the signature
	# of an AIR application is time-stamped, the application can still be installed after the signing
	# certificate expires, because the timestamp verifies that the certificate was valid at the time of signing.
	#
	attr_accessor :tsa

	attr_accessor :target

	attr_accessor :include_files

	attr_accessor :additional_args

	def initialize(file)

		self.application_descriptor = "application.xml"
		self.storetype = "pkcs12"
		self.target = "air"
		self.include_files = []
		@keystore = "cert.p12"

		super(file)

		create_keystore_task

	end

	# define named task first so if desc was called it will be attached to it instead of the file task
	def execute

		fail "You must define 'output' for #{self}" if self.output == nil
		fail "You must define 'application_descriptor'" if self.application_descriptor == nil || !File.exists?(self.application_descriptor)
		fail "You must define 'keystore' for #{self}" if self.keystore == nil
		fail "You must define 'keystore_name' for #{self}" if self.keystore_name == nil
		fail "You must define 'storepass' for #{self}" if self.storepass == nil

		# TODO: Somehow confirm that the initialWindow content is included in the build
		#app_xml = Nokogiri::XML(File.read(application_descriptor))
		#swf = app_xml.at_css("initialWindow > content").content.to_s
		#swf = File.join(@output_dir, swf)
		#puts swf

		command = "#{FlexSDK::adt}"
		command << " -package"
		command << " -tsa #{self.tsa}" if self.tsa != nil
		command << " -storetype #{self.storetype}"
		command << " -keystore #{self.keystore}"
		command << " -storepass #{self.storepass}"
		command << " -target #{target}" if target != nil && target != "air"
		command << " #{self.output}"
		command << " #{self.application_descriptor}"
		command << " #{additional_args}" if self.additional_args != nil
		if self.include_files == nil || self.include_files.length < 1
			command << " -C #{self.output_dir} ."
		else
			self.include_files.each {|entry| command << " -C #{entry}" }
		end
		status = run command, false
		if status.exitstatus != 0
			case status.exitstatus
			when 2
				fail "Usage error\n" + 
					 "Check the command line arguments for errors"
			when 5
				fail "Unknown error\n" +
					 "This error indicates a situation that cannot be explained by common error conditions.\n" +
					 "Possible root causes include incompatibility between ADT and the Java Runtime Environment,\n"
					 "corrupt ADT or JRE installations, and programming errors within ADT."
			when 6
				fail "Could not write to output directory\n" +
					 "Make sure that the specified (or implied) output directory is accessible and\n" +
					 "that the containing drive has sufficient disk space."
			when 7
				fail "Could not access certificate\n" +
					 "Make sure that the path to the keystore is specified correctly: #{self.keystore}\n" +
					 "Make sure that the keystore password is correct: #{self.storepass}"
					 #"Check that the certificate within the keystore can be accessed."
			when 8
				fail "Invalid certificate\n" +
					 "The certificate file is malformed, modified, expired, or revoked."
			when 9
				fail "Could not sign AIR file\n" +
					 "Verify the signing options passed to ADT."
			when 10
				fail "Could not create time stamp\n" +
					 "ADT could not establish a connection to the timestamp server.\n" + 
					 "If you connect to the internet through a proxy server, you may need to configure\n" + 
					 "the JRE proxy settings. There have also been errors reported with Java 7: \n" +
					 "http://www.flashdevelop.org/community/viewtopic.php?p=41221\n" + 
					 "You can disable checking a timestamp server by setting 'tsa' to 'none' in your task"
			when 11
				fail "Certificate creation error\n" +
					 "Verify the command line arguments used for creating signatures."
			when 12
				fail "Invalid input\n" +
					 "Verify file paths and other arguments passed to ADT on the command line."#\n" +
					 #"Be sure the initial content in #{self.application_descriptor} is included in the build:\n" +
					 #"<initialWindow>\n   <content>#{swf}</content>\n</initialWindow>"
			else
				fail "Operation exited with status #{status.exitstatus}"
			end
		end
	end

	def keystore= value
		remove_keystore_task()
		@keystore = value
		create_keystore_task()
	end

	private

	def remove_keystore_task
		Rake::Task[@keystore].clear
	end

	def create_keystore_task
		file self.keystore do
			run "#{FlexSDK::adt} -certificate -cn #{self.keystore_name} 1024-RSA #{self.keystore} #{self.storepass}"
			puts "Certificate created at #{self.keystore} with password '#{self.storepass}'"
		end

		file self.output => self.keystore
	end

end
end