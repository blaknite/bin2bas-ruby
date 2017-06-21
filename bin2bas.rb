#! /bin/ruby

options = {
  'start' => '8080',
}

while ARGV.length > 1
  parts = ARGV.shift.sub(/--/, '').split('=')
  options[parts[0]] = parts[1]
end

options['start'].sub!(/0x/i, '')
options['start'].upcase!

bin = File.open(ARGV.shift, 'r').read.unpack('C*')

print <<~BASIC
  NEW
  CLEAR

  10 REM Hex loader for the RC2014
  20 REM Adapted by Grant Colegate
  30 REM Original code by Filippo Bergamasco and DaveP
  40 REM Version 0.1.0

  100 PRINT "Loading #{bin.length} bytes starting at &H#{options['start']}..."
  120 GOSUB 1000
  130 PRINT "Load complete."
  140 PRINT "Changing jump location..."
  150 GOSUB 2000
  160 PRINT "Done."
  170 PRINT "Starting program..."
  180 PRINT USR(0)
  190 END

  1000 REM Routine to load binary data
  1010 LET ADDR = &H#{options['start']}
  1020 READ A
  1030 IF A > 255 THEN RETURN
  1040 REM Add the line below for verbose output
  1050 REM PRINT HEX$(ADDR), ": ", A
  1060 POKE ADDR, A
  1070 LET ADDR = ADDR + 1
  1080 GOTO 1020

  2000 REM Set pointer (&H8049) to jump to start address
  2010 REM Instruction: jp #{options['start']} (C3 #{options['start']})
  2020 LET ADDR = &H8048
  2030 POKE ADDR, &HC3
  2040 POKE ADDR + 1, &H#{options['start'][2..3]}
  2050 POKE ADDR + 2, &H#{options['start'][0..1]}
  2060 RETURN

BASIC

bin.each_slice(12).with_index do |bytes, i|
  puts "#{5000 + i} DATA #{bytes.join(',')}"
end

print <<~BASIC
  9998 DATA 999

  9999 END

  RUN
BASIC
