# coding: utf-8

class OwnersController < ApplicationController
  # GET /owners
  # GET /owners.xml
  def index
    @owners = Owner.all

    respond_to do |format|
      format.xml  { render :xml => @owners }
    end
  end

  # GET /owners/1
  # GET /owners/1.xml
  def show
    @owner = Owner.find(params[:id])

    
    respond_to do |format|
      format.xml  { render :xml => @owner }
    end
  end

  # GET /owners/new
  # GET /owners/new.xml
  def new
    @owner = Owner.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @owner }
    end
  end

  # POST /owners
  # POST /owners.xml
  def create
    @owner = Owner.new(params[:owner])

    respond_to do |format|
      if @owner.save
        format.xml  { render :xml => @owner.id, :status => :created }
      else
        format.xml  { render :xml => @owner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /owners/1
  # PUT /owners/1.xml
  def update
    @owner = Owner.find(params[:id])

    respond_to do |format|
      if @owner.update_attributes(params[:owner])
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @owner.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /owners/1
  # DELETE /owners/1.xml
  def destroy
    @owner = Owner.find(params[:id])
    @owner.destroy

    respond_to do |format|
      format.xml  { head :ok }
    end
  end
end
