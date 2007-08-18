# $Id$

require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'

namespace :doc do

  desc 'Generate RDoc documentation'
  Rake::RDocTask.new do |rd|
    rd.main = PROJ.rdoc_main
    rd.options << '-d' if !WIN32 and `which dot` =~ %r/\/dot/
    rd.rdoc_dir = 'doc'

    incl = Regexp.new(PROJ.rdoc_include.join('|'))
    excl = Regexp.new(PROJ.rdoc_exclude.join('|'))
    files = PROJ.files.find_all do |fn|
              case fn
              when excl: false
              when incl: true
              else false end
            end
    rd.rdoc_files.push(*files)

    title = "#{PROJ.name}-#{PROJ.version} Documentation"
    title = "#{PROJ.rubyforge_name}'s " + title if PROJ.rubyforge_name != title

    rd.options << "-t #{title}"
  end

  desc 'Generate ri locally for testing'
  task :ri => :clobber_ri do
    sh "#{RDOC} --ri -o ri ."
  end

  desc 'Remove ri products'
  task :clobber_ri do
    rm_r 'ri' rescue nil
  end

  if PROJ.rubyforge_name && HAVE_RUBYFORGE
    desc "Publish RDoc to RubyForge"
    task :release => %w(doc:clobber_rdoc doc:rdoc) do
      config = YAML.load(
          File.read(File.expand_path('~/.rubyforge/user-config.yml'))
      )

      host = "#{config['username']}@rubyforge.org"
      remote_dir = "/var/www/gforge-projects/#{rubyforge_name}/"
      remote_dir << PROJ.rdoc_remote_dir || PROJ.name
      local_dir = 'doc'

      Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
    end
  end

end  # namespace :doc

task :clobber => %w(doc:clobber_rdoc doc:clobber_ri)

# EOF
