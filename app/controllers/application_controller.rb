class ApplicationController < ActionController::Base
  protect_from_forgery
 	
	def index
		tree = Mtree.instance
	    @list = tree.get_tree
	end
end