require 'spec_helper'

describe OwnersController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/owners" }.should route_to(:controller => "owners", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/owners/new" }.should route_to(:controller => "owners", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/owners/1" }.should route_to(:controller => "owners", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/owners/1/edit" }.should route_to(:controller => "owners", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/owners" }.should route_to(:controller => "owners", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/owners/1" }.should route_to(:controller => "owners", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/owners/1" }.should route_to(:controller => "owners", :action => "destroy", :id => "1") 
    end
  end
end
