ASRake
======

**A Rake library for Actionscript 3, Flex, and AIR projects.**

### `gem install asrake`


Overview
--------

Add the path(s) to your Flex SDK for all systems that will need to run the Rake tasks.
```ruby
FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'
FlexSDK::SDK_PATHS << "C:/develop/sdk/flex_sdk_4.5.1"
FlexSDK::SDK_PATHS << "/opt/lib/adobe/flex_4.6"
```

### Compiler Arguments

Arguments match those passed to the compiler (mxmlc, compc, adt, etc) with hyphens `-` replaced by underscores `_` (e.g., to set the `target-player` compiler argument assign to the `target_player` property)

> Since this is still in development, not all compiler arguments have a property mapped to them. Use `additional_args` to pass whatever text you want into the compiler.

Convenience methods are provided for `include_libraries`, `external_library_path`, and `library_path`; you can instead use `statically_link`, `dynamically_link`, and `statically_link_only_referenced_classes` respectively.


How to Use
----------

### Build a SWF or SWC

```
ASRake::MxmlcTask(task_name = :build, compiler_args = nil) |self|
```
```
ASRake::CompcTask(task_name = :build, compiler_args = nil) |self|
```

You can define the compile arguments elsewhere and pass it to the task, or set them inside the task block, or a combination of both. It is purely preference.

The following snippets produce identical tasks.

```ruby
desc "Build swc"
ASRake::CompcTask.new :build do |build|
# you can store the compiler arguments, for example, maybe we need to know the output_dir later on
#compc = ASRake::CompcTask.new :build do |build|
   build.target_player = 11.0
   build.output = "bin/bin/my_project.swc"
   build.debug = true
   build.source_path << "bin/src"
   build.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
end
```

```ruby
args = ASRake::CompcArguments.new
args.target_player = 11.0
args.output = "bin/bin/my_project.swc"
args.debug = true
args.source_path << "bin/src"
args.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"

desc "Build swc"
ASRake::CompcTask.new :build, args
```

```ruby
args = ASRake::CompcArguments.new
args.target_player = 11.0
args.output = "bin/bin/my_project.swc"
args.debug = false
args.source_path << "bin/src"

desc "Build swc"
ASRake::CompcTask.new :build, args do |compc|
   compc.debug = true
   compc.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
end
```

### Build an AIR

Compile your SWF file as normal, but set the `isAIR` property to true

```ruby
desc "Build app"
ASRake::MxmlcTask.new :build do |build|
	build.load_config << "mxmlc_config.xml"
	build.output = "bin/my_app.swf"
	build.isAIR = true
end
```

Provide the package task with the AIR and keystore information. If the key doesn't exist, it will be created.

> Be sure that the swf file is included in the package (eg, it is included here by packaging everything in the bin directory with `-C bin .`)

```ruby
ASRake::AdtTask.new :package => :build do |package|
	package.output = "bin/my_app.air"
	package.keystore = "my_app_cert.p12"
	package.keystore_name = "my_app"
	package.storepass = "my_app"
	package.tsa = "none"
	package.additional_args = "-C bin ."
end
```

### Version

```
ASRake::VersionTask(task_name = :version, file_name = "VERSION")
```

No additional arguments are needed to create a version task. Once added to your Rakefile, you can run `rake version:help` for information on how versioning works.

If you are fine with the defaults, you can just add:

```ruby
ASRake::VersionTask.new
```

Otherwise you can define the task name and filename as you wish

```ruby
ASRake::VersionTask.new :v, "./config/version.txt"
```

#### Version Sync

There is a task `version:sync` that is run every time the version changes. This can be useful for things like updating configuration files automatically. To use, add a block to the task:

```ruby
#replace :version with whatever you provided to ASRake::VersionTask.new 
namespace :version do
   task :sync do
      #update application.xml
   end
end
```

### Clean

```
ASRake::CleanTask.new(*compiler_args)
```

Provide your compiler arguments to `ASRake::CleanTask` and it will automatically create clean and clobber tasks.

```ruby
swf = ASRake::MxmlcTask.new :build do |build|
	build.load_config << "mxmlc_config.xml"
	build.output = "bin/my_app.swf"
	build.isAIR = true
end

ASRake::CleanTask.new swf
```

### Copy Files

```
ASRake::CopyTask.new(task_name = :copy) |self|
```

Copies files from a source to a destination using file modification time to determing if the copy is necessary or not. Basically it's like creating rake `file` tasks in bulk.

```ruby
ASRake::CopyTask.new :assets do |copy|
	#
	# usage: block_param.add(from, to)
	#

	# use "copy" or "add" at your preference
	copy.copy "src", "bin/src"
	copy.add "src/*.xml", "bin"

	# provide arguments as a hash instead
	copy.add "lib/**/*.swc" => "bin/lib"

	# or in bulk
	copy.add({"conf/a.config" => "bin/default.config", "conf/b.config" => "conf/alt.config"})

	# or do it all in a block
	{
		"src" => "bin/src",
		"src/*.xml" => "bin",
		"lib/**/*.swc" => "bin/lib",
		"conf/a.config" => "bin/default.config",
		"conf/b.config" => "conf/alt.config"
	}.each {|from, to| copy.add from, to}
end
```