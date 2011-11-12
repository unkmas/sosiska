require 'couchrest_model'
class Wiki < CouchRest::Model::Base
	#include CouchPotato::Persistence
	#use_database 'wiki'

	property :title
	property :text

	#view_by :_id, :value => :title
	view_by :title , :map =>
    	"function(doc) {
   			 if ((doc['type'] == 'Wiki') && (doc['_id'] != null)) {
    			emit(doc['_id'], doc['title']);
    		}
    	}"

end