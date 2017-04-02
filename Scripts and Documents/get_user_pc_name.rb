def self.get_environment_variable(variable, length = 256)
  testvalue = "\0" * length
  Win32API.new('Kernel32', 'GetEnvironmentVariable', 'PPL', 'V').call(variable, testvalue, length)
  returnvalue = testvalue[0, testvalue.index("\0")]
  if returnvalue[-1, 1] != "\\" && returnvalue[-1, 1] != '/'
    returnvalue+= '/'
  end
  returnvalue.gsub!(/\\/) { '/' }
  returnvalue
end
$Username = get_environment_variable('USERNAME', 256)
$Username.delete! ('/')