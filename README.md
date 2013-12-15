# ASRake

**Quickly and easily create build scripts for Actionscript 3, Flex, and AIR projects.**

## Installation

### `gem install asrake`

## Usage

If you have an environment variable `FLEX_HOME` set to the root path of your Flex SDK, then no further action is necessary.

If you want to manually define the path(s) to your Flex SDK for all systems that will need to run the build scripts, you can do so by appending to the array `FlexSDK::SDK_PATHS` like so:

```ruby
FlexSDK::SDK_PATHS << 'C:\develop\sdk\flex_sdk_4.6.0.23201'
FlexSDK::SDK_PATHS << "C:/develop/sdk/flex_sdk 4.5.1"
FlexSDK::SDK_PATHS << "/opt/lib/adobe/flex_4.6"
```

### Compiler Arguments

Arguments match those passed to the compiler (mxmlc, compc, adt, etc) with hyphens `-` replaced by underscores `_` (e.g., to set the `target-player` compiler argument assign to the `target_player` property)

> Since this is still in development, not all compiler arguments have a property mapped to them. Use `additional_args` to pass whatever text you want into the compiler.

Convenience methods are provided for `include_libraries`, `external_library_path`, and `library_path`; you can instead use `statically_link`, `dynamically_link`, and `statically_link_only_referenced_classes` respectively.

### Build a SWF or SWC

```
ASRake::Mxmlc.new(output)
```
```
ASRake::Compc.new(output)
```

Assign arguments for your build and optionally run it with a friendlier-named task:

```ruby
swc = ASRake::Compc.new "bin/my_project.swc"
swc.target_player = 11.9
swc.debug = true
swc.source_path << "src"
swc.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc" # alternate name for "library_path"

desc "Build Project"
task :build => swc
```

You can chain together complex builds and the dependencies will be properly handled:

```ruby
lib_swc = ASRake::Compc.new "lib/other_project/bin/proj.swc"
lib_swc.target_player = 11.5
lib_swc.source_path << "lib/other_project/src"

main_swc = ASRake::Compc.new "bin/my_project.swc"
main_swc.target_player = 11.5
main_swc.debug = true
main_swc.source_path << "src"
main_swc.statically_link << lib_swc # alternate name for "include_libraries"

desc "Build Project"
task :build => main_swc
```

### Include ASDoc in a SWC

If you are compiling with `Compc`, you can set the field `include_asdoc` in order to have documentation added to your output swc.

```ruby
desc "Build Project"
swc = ASRake::Compc.new "bin/my_project.swc"
swc.target_player = 11.0
swc.source_path << "src"
swc.include_asdoc = true
```

### Build using AIR

Compile your SWF file as normal, but set the `isAIR` property to true

```ruby
desc "Build app"
my_app = ASRake::Mxmlc.new "bin/my_app.swf"
my_app.load_config << "mxmlc_config.xml"
my_app.isAIR = true
```

To package the `.air` file, provide the package task with the file and keystore information. If the provided key doesn't exist, it will be created for you.

> Be sure that the swf file is included in the package. (In the below sample code it is included by packaging everything in the bin directory with the line: `air.include_files << "bin ."`)

```ruby
air = ASRake::Adt.new "deploy/my_app.air"
air.keystore = "cert.p12"
air.keystore_name = "my_app"
air.storepass = "my_app"
air.tsa = "none"
air.include_files << "bin ."
```

### Versioning your project

```
ASRake::VersionTask(task_name = :version, file_name = "VERSION")
```

No additional arguments are needed to create a version task. Once added to your Rakefile, you can run `rake version:help` for information on how versioning works.

If you are fine with the defaults (see above), you can just add:

```ruby
ASRake::VersionTask.new
```

Otherwise you can define the task name and filename as you wish

```ruby
ASRake::VersionTask.new :v, "./config/version.txt"
```

#### Version Sync

The task `version:sync` is run every time the version changes. This hook can be useful for things like updating configuration files automatically. To use, add an additional block to the task like so:

```ruby
# replace :version with whatever you provided to ASRake::VersionTask.new 
namespace :version do
	task :sync do
		# update version info in application.xml
	end
end
```

## Additional Functionality

### New copy method

ASRake introduces a new copy method `cp_u` on FileUtils and in the global namespace.

This copies all files from the source that *do not exist* or are *older* at the destination

```ruby
# copy a single file to a destination folder
cp_u "path/to/file.xml", "/dest/"

# copy a single file to a differently named file in the destination folder
cp_u "path/to/file.xml", "/dest/dest.xml"

# copy an array of explicitly-enumerated files
cp_u %w{application.xml my_app.swf config.json}, "/dest"

# use FileList, Dir.glob(), or other standard methods to copy groups of files
cp_u FileList["lib/**/*.swc"], "bin/lib"
```

### Build without a Rake task

You don't need to create a named Rake task in order to build your project. As an alternative, you can simply call `execute()` on an instance of Compc or Mxmlc.

> Note that this will not do any dependency checks, so the build will run even if it is unnecessary

```ruby
args = ASRake::Compc.new "bin/my_project.swc"
args.target_player = 11.0
args.source_path << "src"
args.statically_link_only_referenced_classes << "lib/lib_used_in_project.swc"
args.execute()
```

## Contributing Guidelines

1. Fork this project
2. Create a feature branch
3. Make your changes
4. Create a Pull Request
