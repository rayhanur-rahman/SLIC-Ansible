# makes Seth think it's running on a certain platform..useful for unit testing
# platform-specific functionality.
#
# If a block is given yields to the block with +RUBY_PLATFORM+ set to
# 'i386-mingw32' (windows) or 'x86_64-darwin11.2.0' (unix).  Usueful for
# testing code that mixes in platform specific modules like +Seth::Mixin::Securable+
# or +Seth::FileAccessControl+
def platform_mock(platform = :unix, &block)
  Seth::Platform.stub(:windows?).and_return(platform == :windows ? true : false)
  ENV['SYSTEMDRIVE'] = (platform == :windows ? 'C:' : nil)

  if platform == :windows
    Seth::Config.set_defaults_for_windows
  else
    Seth::Config.set_defaults_for_nix
  end

  if block_given?
    mock_constants({"RUBY_PLATFORM" => (platform == :windows ? 'i386-mingw32' : 'x86_64-darwin11.2.0'),
                    "File::PATH_SEPARATOR" => (platform == :windows ? ";" : ":"),
                    "File::ALT_SEPARATOR" => (platform == :windows ? "\\" : nil) }) do
yield
    end
  end
end
