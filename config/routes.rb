Sosiska::Application.routes.draw do

  root :to => 'application#index'

  # Adding Article to the root
  match 'add' => "wiki#add", :sections => ""
  match 'save' => "wiki#save", :sections => ""

  # sections is a path to the Article
  # for example: name1/name2
  match '*sections/edit' => "wiki#edit"
  match '*sections/add' => "wiki#add"
  match '*sections/save' => "wiki#save"
  match '*sections/update' => "wiki#update"
  match '*sections' => "wiki#show" 

end
