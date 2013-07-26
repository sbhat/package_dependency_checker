package_dependency_checker
==========================

   rvm install jruby-1.7.4
   git clone https://github.com/sbhat/package_dependency_checker.git
   cd package_dependency_checker
   git checkout -b tree_structure origin/tree_structure
   bundle install
   bundle exec rspec .
   source=japa.parser dir=<project_dir>/package_dependency_checker/spec/src target=japa.parser.ast.* ruby main.rb
