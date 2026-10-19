# -*- ruby -*-

def version
  configure_ac = File.read("configure.ac")
  configure_ac[/^AC_INIT\(\[SigScheme\], \[(.+?)\]/, 1]
end

desc "Tag"
task :tag do
  sh("git", "tag", "-a", version, "-m", "SigScheme #{version}!!!")
  sh("git", "push", "origin", version)
end

namespace :version do
  desc "Bump version"
  task :bump do
    next_version = version.succ
    configure_ac =
      File.read("configure.ac").
        gsub(/^(AC_INIT\(\[SigScheme\], )\[.+?\]/) {"#{$1}[#{next_version}]"}
    File.write("configure.ac", configure_ac)
    meson_build =
      File.read("meson.build").
        sub(/^(project\(.*?version:\s*')\d+\.\d+\.\d+/m) {"#{$1}#{next_version}"}
    File.write("meson.build", meson_build)
    sigscheme_h_path = "include/sigscheme/sigscheme.h"
    sigscheme_h =
      File.read(sigscheme_h_path).
        sub(/^(#define SSCM_VERSION_STRING\s+)".+?"/) do
          "#{$1}\"#{next_version}\""
        end
    major, minor, patchlevel = next_version.split(".")
    {
      "MAJOR" => major,
      "MINOR" => minor,
      "PATCHLEVEL" => patchlevel,
    }.each do |name, value|
      sigscheme_h =
        sigscheme_h.sub(/^(#define SSCM_VERSION_#{name}\s+)\(\d+\)/) do
          "#{$1}(#{value})"
        end
    end
    File.write(sigscheme_h_path, sigscheme_h)
    sh("git", "add", "configure.ac", "meson.build", sigscheme_h_path)
    sh("git", "commit", "-m", "Bump version")
    sh("git", "push")
  end
end

desc "Release"
task :release => ["tag", "version:bump"]
