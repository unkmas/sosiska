class WikiController < ApplicationController

before_filter :exist_filter
caches_page :show


	def show
		@wiki = Wiki.get(params[:sections])
		tree = Mtree.instance
		@list = tree.tree(params[:sections])
	end

	def edit
		@wiki = Wiki.get(params[:sections])
		@wiki.text = encode(@wiki.text)
	end

	def add
	end

	def update
		@wiki = Wiki.get(params[:sections])

		# if new title, clear cash
		if( @wiki.title != params[:title])
			@wiki.title = params[:title]
			expire_nodes(@wiki.id)
		end

		@wiki.text = decode(params[:text])
		@wiki.save

		expire_page(:action => 'show', :sections => params[:sections])
		redirect_to "/" + params[:sections]
	end

	def save	
		if(!params[:sections].empty?) 
			@id = params[:sections] + "/" + params[:name]
		else # root path
			@id = params[:name]
		end
		text = decode(params[:text])
		
		@wiki = Wiki.new(:title => params[:title], :text => text , :id => @id)
		@wiki.save

		# clear cash
		expire_nodes(@id)
		# add new node to a tree
		tree = Mtree.instance
		tree.add_node(params[:sections], params[:name],params[:title] )
		
		redirect_to  "/" + @wiki.id
	end

private

  
  def exist_filter
  	if(!params[:sections].empty?)
    	if(!Rails.cache.exist?(params[:sections]))
    		redirect_to "/404.html"
   		end
  	end
  end

  # Removing cash of all parents of current node
	def expire_nodes(path)
		arr = path.split('/')
		arr.reverse.each do |arr|
			expire_page(:action => 'show', :sections => path)
			path.slice!(-1*arr.length,arr.length)
			if(path.last == "/")
				path.slice!(-1,1)
			end
			p path
		end
	end

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

end