Gem::Specification.new do |s|
  s.name               = "arelizer"
  s.version            = "0.0.1"
  s.authors = ["Melinda Weathers"]
  s.date = %q{2013-05-22}
  s.description = %q{A gem for converting pre-arel ActiveRecord queries to their non-deprecated equivalents}
  s.email = %q{melinda@agileleague.com}
  s.files = ["lib/arelizer.rb", "lib/arelizer/sexp_extensions.rb"]
  s.homepage = %q{http://github.com/agileleague/arelizer.git"}
  s.require_paths = ["lib"]
  s.summary = %q{ActiveRecord Query Arel-izer}

  s.add_dependency 'ruby_parser'
  s.add_dependency 'ruby2ruby'

end
