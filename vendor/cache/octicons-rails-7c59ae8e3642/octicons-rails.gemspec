# -*- encoding: utf-8 -*-
# stub: octicons-rails 3.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "octicons-rails".freeze
  s.version = "3.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Maksim Berjoza".freeze, "Julien Letessier".freeze]
  s.date = "2017-10-16"
  s.description = "".freeze
  s.email = ["maksim.berjoza@gmail.com".freeze, "julien.letessier@gmail.com".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze, "app/assets/fonts".freeze, "app/assets/fonts/octicons-local.ttf".freeze, "app/assets/fonts/octicons.eot".freeze, "app/assets/fonts/octicons.svg".freeze, "app/assets/fonts/octicons.ttf".freeze, "app/assets/fonts/octicons.woff".freeze, "app/assets/stylesheets/octicons.css.erb".freeze, "lib/octicons-rails".freeze, "lib/octicons-rails.rb".freeze, "lib/octicons-rails/engine.rb".freeze, "lib/octicons-rails/version.rb".freeze]
  s.homepage = "https://github.com/torbjon/octicons".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Awesome Github Octicons with Rails asset pipeline".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, ["< 5.0", ">= 3.2"])
    else
      s.add_dependency(%q<railties>.freeze, ["< 5.0", ">= 3.2"])
    end
  else
    s.add_dependency(%q<railties>.freeze, ["< 5.0", ">= 3.2"])
  end
end
