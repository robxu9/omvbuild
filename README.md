# omvbuild

...is a Docker container that build a package from the requested variables.
It does not make any assumptions on where you get the package -- merely
builds whatever it's given and outputs the RPMS.

This is very basic - there are no signatures, no repodata creation, nothing.
So basically mock, but in a Docker container, making it portable across
distributions.

## Running

I usually run this in my Jenkins, so this is about what I have for it:

```bash
cd $WORKSPACE
mkdir -pv $WORKSPACE/{build,target}
timeout -k 2m 1m git clone --depth=1 git@abf.io:openmandriva/${PACKAGE}.git $WORKSPACE/src

cat<<EOF>$WORKSPACE/abf_yml.rb
#!/usr/bin/env ruby
require 'yaml'
require 'optparse'

project_path = ''
OptionParser.new do |o|
  o.on('-p project_path') { |p| project_path = p }
  o.parse!
end

abf_yml = "#{project_path}/.abf.yml"
if File.exists?(abf_yml)
  file = YAML.load_file(abf_yml)
  file['sources'].each do |k, v|
    puts "==> Downloading '#{k}'..."
    system "curl -L http://file-store.rosalinux.ru/api/v1/file_stores/#{v} -o #{project_path}/#{k}"
    puts "Done."
  end
end
EOF

ruby $WORKSPACE/abf_yml.rb -p $WORKSPACE/src
```

Followed by:

```bash
cd $WORKSPACE
envsubst<<EOM>env.list
TARGET=$TARGET
REPOSITORY=$REPOSITORY
BRANCH=$BRANCH
PACKAGE=$PACKAGE
ARCH=$ARCH
EOM

docker run --rm -v "$WORKSPACE":/workspace --privileged --env-file ./env.list omvbuild
```

It's necessary to use `--privileged` in order to mount new namespaces in the
resulting chroot. I'm open to suggestions to get rid of it.

## License
Licensed under the [MIT license](http://robxu9.mit-license.org/).
