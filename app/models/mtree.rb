class Mtree
require 'tree'
require 'singleton'
include Singleton
 
	def initialize
		
		@articles = Wiki.by_title
		@tree = Tree::TreeNode.new('root','')

		# creating tree
		@articles.each do |a|
			# Add article to cash.
			Rails.cache.write(a.id,a.title)

			array = a.id.split('/')
			@cur_branch = @tree

			# Walking through a tree
			array.each do |arr|
				if( !@cur_branch[arr] )
					@cur_branch << Tree::TreeNode.new(arr)
				end
				@cur_branch = @cur_branch[arr]
			end

		  @cur_branch.content = "<a href='/#{a.id}'>#{a.title}</a>"	
		end
		
	end	
	
	# Get node from tree by path.
	def get_node(path)
		array = path.split('/')
		@cur_branch = @tree
		array.each {|arr| @cur_branch = @cur_branch[arr]}

		@cur_branch
	end	

	def get_tree(tree = @tree)
	  	
	  	list = "<li>#{tree.content}</li>\n"
	  	if(tree.has_children?)
	  		list += "<ul>\n"
			tree.children.each do |child|
				list += get_tree(child)
			end
			list += "</ul>\n"
		end

		list
	end

	# Getting an html-tree.
	def tree(path = 'root')	
		"<ul>#{get_tree(get_node(path))}</ul>\n"
	end
	
	def add_node(name, title, path = '')
		id = if( !path.empty?)
			 	[ path, name ].join('/')
			else
				name
			end
		get_node(path) << Tree::TreeNode.new(name,"<a href='/#{id}'>#{title}</a>")
		Rails.cache.write(id, title)
	end		

end