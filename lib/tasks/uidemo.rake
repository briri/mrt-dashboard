require 'fileutils'
require 'open3'
require 'pathname'

class UIDemo
  attr_reader :project_root_path

  def initialize(project_root)
    @project_root_path = Pathname.new(project_root)
  end

  def compile_demo!
    raise 'Can’t process SCSS without sass or sassc' unless sass_cmd
    raise "Can’t locate UI library #{ui_library_path}" unless ui_library_path.exist?
    puts "Processing source files from #{ui_library_path}"
    puts "                   to target #{demo_path}\n\n"
    sass_lint
    clear_demo_dir!
    process_source_files!
  end

  private

  def sass_cmd
    @sass_cmd ||= if system('which sassc > /dev/null 2>&1')
                    'sassc -t expanded'
                  elsif system('which sass > /dev/null 2>&1')
                    'sass'
                  end
  end

  def ui_library_path
    @ui_library_path ||= project_root_path + 'ui-library'
  end

  def ui_library_path_str
    ui_library_path.to_s
  end

  def ui_library_path_relative
    @ui_library_path_relative ||= ui_library_path.relative_path_from(project_root_path)
  end

  def demo_path
    @demo_path ||= project_root_path + 'public/demo'
  end

  def demo_path_str
    @demo_path_str ||= demo_path.to_s
  end

  def demo_path_relative
    @demo_path_relative ||= demo_path.relative_path_from(project_root_path)
  end

  def sass_lint
    if system('which sass-lint > /dev/null 2>&1')
      puts "Checking SCSS style:\n  #{sass_lint_cmd}\n\n"
      output, status = run_ext(sass_lint_cmd)
      (warn(output); raise) unless status == 0
    else
      puts 'sass-lint not found in $PATH; skipping style checks'
    end
  end

  def sass_lint_cmd
    @sass_lint_cmd ||= begin
      cmd = <<~LINT
        sass-lint --config #{ui_library_path_relative}/scss/.sass-lint.yml
                  '#{ui_library_path_relative}/scss/*.scss'
                  -v -q --max-warnings=0
      LINT
      cmd.gsub(/\s +/, ' ').strip
    end
  end

  def run_ext(cmd)
    Open3.capture2e(cmd)
  end

  def clear_demo_dir!
    puts "Clearing target directory\n\n"
    FileUtils.remove_dir(demo_path_str) if File.directory?(demo_path_str)
  end

  def process_source_files!
    puts 'Processing files'
    Dir.glob("#{ui_library_path}/**/*").each do |infile|
      process_file(infile) unless skip?(infile)
    end
  end

  def skip?(infile)
    return true if File.directory?(infile)
    return true if File.basename(infile) == '.sass-config.yml'
    false
  end

  def process_file(infile)
    if infile.end_with?('.scss')
      return if File.basename(infile).start_with?('_')
      return compile_scss(infile)
    end
    copy_to_demo(infile)
  end

  def compile_scss(infile)
    outfile = infile.sub(ui_library_path_str, demo_path_str).gsub('scss', 'css')
    FileUtils.mkdir_p(File.expand_path('..', outfile))
    puts "  Compiling #{relative_path(infile)} to #{relative_path(outfile)}"
    output, status = run_ext("#{sass_cmd} '#{infile}' > '#{outfile}'")
    (warn(output); raise) unless status == 0
  end

  def copy_to_demo(infile)
    outfile = infile.sub(ui_library_path_str, demo_path_str)
    FileUtils.mkdir_p(File.expand_path('..', outfile))
    puts "  Copying #{relative_path(infile)} to #{relative_path(outfile)}"
    FileUtils.cp(infile, outfile)
  end

  def relative_path(path)
    pathname = path.respond_to?(:relative_path_from) ? path : Pathname.new(path)
    pathname.relative_path_from(project_root_path)
  end
end

task :uidemo do
  project_root = File.expand_path('../..', __dir__)
  UIDemo.new(project_root).compile_demo!
end