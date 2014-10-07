def run_command(cmd)
  IO.popen(cmd).inject('') do |_, line|
    puts line.chomp
    line
  end
end

def capture_stdout(stdout = $stdout, &block)
  $stdout = fakeout = StringIO.new
  block.call
  fakeout.string
ensure
  $stdout = stdout
end
