Gem::Specification.new do |s|
  s.name               = "wherelizer"
  s.version            = "0.0.5"
  s.authors = ["Melinda Weathers"]
  s.date = %q{2013-06-06}
  s.description = %q{A gem for converting pre-arel ActiveRecord queries to their non-deprecated equivalents}
  s.email = %q{melinda@agileleague.com}
  s.files = ["lib/wherelizer.rb", "lib/wherelizer/sexp_extensions.rb"]
  s.homepage = %q{http://github.com/agileleague/wherelizer.git}
  s.require_paths = ["lib"]
  s.summary = %q{ActiveRecord Query Updater}

  s.add_dependency 'ruby_parser'
  s.add_dependency 'ruby2ruby'

end
