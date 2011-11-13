class Mtree
require 'tree'
require 'singleton'
include Singleton
 
	def initialize
		p "-----------------------------------------------"
		@articles = Wiki.by_title
		@tree = Tree::TreeNode.new('root','')

		#creating tree
		@articles.each do |a|
			# add article to cash
			Rails.cache.write(a.id,a.title)

			array = a.id.split('/')
			@cur_branch = @tree

			array.each do |arr|
				if( !@cur_branch[arr] )
					@cur_branch << Tree::TreeNode.new(arr)
				end
				@cur_branch = @cur_branch[arr]
			end
		  @cur_branch.content = "<a href='/#{a.id}'>#{a.title}</a>"	
		end

	end	
	
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

	def tree(path = 'root')	
		"<ul>#{get_tree(get_node(path))}</ul>\n"
	end
	
	def add_node(path = 'root', name, title)
		id = path + "/" + name
		get_node(path) << Tree::TreeNode.new(name,"<a href='/#{path}'>#{title}</a>")
		Rails.cache.write(id, title)
	end		

end