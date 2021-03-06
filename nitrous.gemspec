# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nitrous}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Austin Taylor", "Paul Nicholson"]
  s.date = %q{2010-06-25}
  s.default_executable = %q{nos}
  s.description = %q{}
  s.email = %q{austin.taylor@gmail.com}
  s.executables = ["nos"]
  s.files = [
    ".gitignore",
     "Rakefile",
     "VERSION",
     "cmd_test",
     "command_line.rb",
     "example.rb",
     "init.rb",
     "lib/core_ext.rb",
     "lib/nitrous.rb",
     "lib/nitrous/assertions.rb",
     "lib/nitrous/daemon.rb",
     "lib/nitrous/daemon_controller.rb",
     "lib/nitrous/http_io.rb",
     "lib/nitrous/integration_test.rb",
     "lib/nitrous/progress_bar.rb",
     "lib/nitrous/rails_test.rb",
     "lib/nitrous/server.rb",
     "lib/nitrous/test.rb",
     "lib/nitrous/test_block.rb",
     "lib/nitrous/test_context.rb",
     "lib/nitrous/test_result.rb",
     "lib/rails_ext.rb",
     "nitrous.gemspec",
     "rails_env.rb",
     "test/assertion_test.rb",
     "test/test_test.rb",
     "test_helper.rb"
  ]
  s.homepage = %q{http://github.com/austintaylor/nitrous}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A half-baked integration testing framework}
  s.test_files = [
    "test/assertion_test.rb",
     "test/test_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

