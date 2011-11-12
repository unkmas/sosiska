#!/usr/bin/env ruby
def decode(str)

	# //som_str//  => <b>some_str</b>	
	str.gsub!(/\\\\.*\\\\/) {|s| 
		s.slice!(0,2)
		s.slice!(-2,2)
		"<b>" + s + "</b>"
	}

	# **som_str**  => <i>some_str</i>
	str.gsub!(/\*\*.*\*\*/){ |s|
		s.slice!(0,2)
		s.slice!(-2,2)
		"<i>" + s + "</i>"
	}

	#((path text)) => <a href ='/path'>text</a>
	str.gsub!(/\(\([^\s]*.*\)\)/){ |s|
		s.slice!("((")
		s.slice!("))")
		a = s.split(" ")
		"<a href ='/#{a[0]}'>#{a[1]}</a>"
	}

	str
end

def encode(str)

	str.gsub!(/<b>.*<\/b>/) {|s|
		s.slice!("<b>")
		s.slice!("</b>")
		"\\\\" + s + "\\\\"
	}

	str.gsub!(/<i>.*<\/i>/) {|s|
		s.slice!("<i>")
		s.slice!("</i>")
		"**" + s + "**"
	}
	

	str.gsub!(/<a.*.\/a>/) {|s|
		s.slice!("<a href ='/")
		s.slice!("</a>")
		a = s.split("'>")
		"((#{a[0]} #{a[1]}))"
	}

	str
end

p decode("**fdsa**")