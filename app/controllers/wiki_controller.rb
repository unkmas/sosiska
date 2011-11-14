class WikiController < ApplicationController

require Sosiska::Application.root + "lib/markup.rb"

before_filter :exist_filter
caches_page :show


	def show
		@wiki = Wiki.get(params[:sections])
		tree = Mtree.instance
		@list = tree.tree(params[:sections])
	end

	def edit
		@wiki = Wiki.get(params[:sections])
		@wiki.text = Markup.dump(@wiki.text)
	end

	def add
	end

	def update
		@wiki = Wiki.get(params[:sections])

		# If new title, clear parent`s cash.
		if( @wiki.title != params[:title] && !params[:title].empty?)
			@wiki.title = params[:title]
			expire_nodes(@wiki.id.dup)
		end

		@wiki.text = Markup.load(params[:text])
		@wiki.save

		expire_page(:action => 'show', :sections => params[:sections])
		redirect_to "/" + params[:sections]
	end

	def save
		id = if !params[:sections].empty?
  			[ params[:sections], params[:name] ].join '/'
		else
  			params[:name]
		end

		text = Markup.load(params[:text])
		@wiki = Wiki.new(:title => params[:title], :text => text , :id => id)
		@wiki.save

		# clear cash
		expire_nodes(id.dup)

		# Add new node to a tree.
		tree = Mtree.instance
		tree.add_node( params[:name],params[:title], params[:sections] )

		redirect_to  "/" + id
	end

private

  
  	def exist_filter
  		if( !params[:sections].empty? )
    		if( !Rails.cache.exist?(params[:sections]) )
    			redirect_to "/404.html"
   			end
  		end
  	end

  # Removing cash of all parents of current node.
	def expire_nodes(path)
		arr = path.split('/')

		arr.reverse.each do |arr|
			expire_page(:action => 'show', :sections => path)
			
			path.slice!( -1*arr.length,arr.length )
		
			if(path.last == "/")
				path.slice!(-1,1)
			end

		end
	end

end