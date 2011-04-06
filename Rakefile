require 'rubygems'

desc "Install gems"
task :install do
  Dir.glob('*.gemspec').each do |gemspec|
    puts "build: #{gemspec}"
    dir = File.dirname(gemspec)
    gemspec_file = File.basename(gemspec)
    gemfile_basename = File.basename(gemspec_file,'.gemspec')
    gem_bin = `which gem`
    use_sudo = gem_bin.start_with?(ENV['HOME']) ? "" : "sudo"
    puts "gem build #{gemspec_file} && #{use_sudo} gem install #{gemfile_basename}-*.gem" 
    system "gem build #{gemspec_file} && #{use_sudo} gem install #{gemfile_basename}-*.gem" 
  end
end

desc "Build gem"
task :build do
  gemspec = "abstract-tables.gemspec"
  gemspec_file = File.basename(gemspec)
  gemfile_basename = File.basename(gemspec_file,'.gemspec')
  gem_bin = `which gem`
  use_sudo = gem_bin.start_with?(ENV['HOME']) ? "" : "sudo"
  system "gem build #{gemspec_file} && #{use_sudo} gem install #{gemfile_basename}-*.gem" 
end
