require 'spec_helper'

describe UsersController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/users" }.should route_to(:controller => "users", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/users/new" }.should route_to(:controller => "users", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/users/1" }.should route_to(:controller => "users", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/users/1/edit" }.should route_to(:controller => "users", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/users" }.should route_to(:controller => "users", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/users/1" }.should route_to(:controller => "users", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/users/1" }.should route_to(:controller => "users", :action => "destroy", :id => "1") 
    end

    it "recognizes and generates #resetmypassword" do
      { :get => "/users/1/resetmypassword" }.should route_to(:controller => "users", :action => "resetmypassword", :id => "1")
    end

    it "recognizes and generates #resetmypasswordbyemail" do
      { :get => "/users/resetmypasswordbyemail" }.should route_to(:controller => "users", :action => "resetmypasswordbyemail")
    end

    it "recognizes and generates #resetmypassword" do
      { :get => "/users/resetpassword/passwd" }.should route_to(:controller => "users", :action => "resetpassword", :id => "passwd")
    end

    it "recognizes and generates #email" do
      { :get => "/users/email/code" }.should route_to(:controller => "users", :action => "email", :id => "code")
    end

    it "recognizes and generates #email.xml" do
      { :get => "/users/email/code.xml" }.should route_to(:controller => "users", :action => "email", :id => "code", :format => "xml")
    end

    it "recognizes and generates #authenticate" do
      { :post => "/users/authenticate" }.should route_to(:controller => "users", :action => "authenticate")
    end

    it "recognizes and generates #authenticate.xml" do
      { :post => "/users/authenticate.xml" }.should route_to(:controller => "users", :action => "authenticate", :format => 'xml')
    end

    it "recognizes and generates #identify" do
      { :get => "/users/identify" }.should route_to(:controller => "users", :action => "identify")
    end
  end
end
