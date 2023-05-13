# -*- encoding: utf-8 -*-
# stub: committee-rails 0.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "committee-rails".freeze
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["willnet".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-04-11"
  s.description = "Committee for rails".freeze
  s.email = ["netwillnet@gmail.com".freeze]
  s.homepage = "https://github.com/willnet/committee-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.13".freeze
  s.summary = "Committee for rails".freeze

  s.installed_by_version = "3.4.13" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<committee>.freeze, [">= 5.0.0"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<railties>.freeze, [">= 0"])
end
