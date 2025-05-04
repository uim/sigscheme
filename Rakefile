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
    sh("git", "add", "configure.ac")
    sh("git", "commit", "-m", "Bump version")
    sh("git", "push")
  end
end

desc "Release"
task :release => ["tag", "version:bump"]
