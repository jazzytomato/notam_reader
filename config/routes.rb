Rails.application.routes.draw do
  root 'parser#new'  
  post 'parser/run' => 'parser#run', as: :run
end
