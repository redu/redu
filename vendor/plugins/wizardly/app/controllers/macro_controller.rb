class MacroController < ApplicationController

  act_wizardly_for :user, :form_data=>:sandbox,
    :completed=>{:controller=>:main, :action=>:finished}, 
    :canceled=>{:controller=>:main, :action=>:canceled}  
  
end
