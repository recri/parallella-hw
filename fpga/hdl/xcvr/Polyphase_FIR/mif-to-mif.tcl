#!/usr/bin/tclsh8.6

#
# translate Altera .mif files
# into Xilinx .mif files
# name the Xilinx .mif files
# with a leading x.
#

#
# DEPTH = 1024;
# WIDTH = 18;
# ADDRESS_RADIX = DEC;
# DATA_RADIX =  DEC;
# CONTENT
# BEGIN 
# addr : data ;
# END

proc mif-install {dictname field value} {
    upvar $dictname d
    dict set d $field $value
    # puts "$field = $value"
}
proc mif-install-data {dictname addr value} {
    upvar $dictname d
    switch [mif-addr-radix $d] {
	DEC { scan $addr %d taddr }
	HEX { scan $addr %x taddr }
	OCT { scan $addr %o taddr }
	BIN { scan $addr %b taddr }
	default { error "unknown address radix: [mif-addr-radix $d]" }
    }
    dict set d "@$taddr" $value
    # puts "@$taddr ($addr) = $value"
}
proc mif-parse {mif} {
    set state {start}
    set d [dict create type mif]
    foreach line [split [string trim $mif] \n] {
	switch -regexp -matchvar v $line {
	    {^DEPTH\s*=\s*([^\s]+);\s*$} {
		mif-install d DEPTH [lindex $v 1]
	    }
	    {^WIDTH\s*=\s*([^\s]+);\s*$} {
		mif-install d WIDTH [lindex $v 1]
	    }
	    {^ADDRESS_RADIX\s*=\s*([^\s]+);\s*$} {
		mif-install d ADDRESS_RADIX [lindex $v 1]
	    }
	    {^DATA_RADIX\s*=\s*([^\s]+);\s*$} {
		mif-install d DATA_RADIX [lindex $v 1]
	    }
	    {^CONTENT\s*$} {}
	    {^BEGIN\s*$} {}
	    {^\s*([^\s]+)\s*:\s*([^\s]+)\s*;\s*$} {
		mif-install-data d [lindex $v 1] [lindex $v 2]
	    }
	    {^END;$} {
	    }
	    default {
		error "missing format line: $line"
	    }
	}
    }
    return $d
}
proc mif-data-radix {mif} { return [dict get $mif DATA_RADIX] }
proc mif-data-radix-as-integer {mif} {
    switch [mif-data-radix $mif] {
	HEX { return 16 }
	DEC { return 10 }
	OCT { return 8 }
	BIN { return 2 }
	default { error "unknown radix name: [mif-data-radix $mif]" }
    }
}
proc mif-addr-radix {mif} { return [dict get $mif ADDRESS_RADIX] }
proc mif-width {mif} { return [dict get $mif WIDTH] }
proc mif-data-lines {mif} {
    set current -1
    set lines {}
    dict for {name value} $mif {
	switch -glob $name {
	    @* {
		set next [string range $name 1 end]
		while {[incr current] < $next} {
		    lappend lines 0
		    puts ">> insert 0 @$current"
		}
		lappend lines $value
	    }
	}
    }
    return $lines
}

proc mif-to-coe {mif} {
    # coe specifies radix and vector of values
    return [format "memory_initialization_radix=%s;\nmemory_initialization_vector=\n%s;\n" \
		[mif-data-radix-as-integer $mif] [join [mif-data-lines $mif] ",\n"] ]
}

foreach file [glob coef*.mif] {
    puts ">>>>>>>>> processing $file"
    set fp [open $file r]
    set mif [mif-parse [read $fp]]
    close $fp
    set fp [open "x$file" w]
    foreach line [mif-data-lines $mif] {
	switch [mif-data-radix $mif] {
	    HEX { scan $line %x data }
	    DEC { scan $line %d data }
	    OCT { scan $line %o data }
	    BIN { scan $line %b data }
	    default { error "unknown radix name: [mif-data-radix $mif]" }
	}
	set out1 [format %064b $data]
	set out2 [string range $out1 [expr {64-[mif-width $mif]}] end]
	puts $fp "$out2 <- $out1 <- $data"
    }
    close $fp
}
