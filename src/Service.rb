require 'sinatra'
require 'sinatra/namespace'
require 'will_paginate/array'
require 'sinatra/cross_origin'
require 'json'
require './DAO'
set :show_exceptions, :after_handler
set :port, 8080
set :bind, '0.0.0.0'

configure do
    enable :cross_origin
end

before do
    content_type 'application/json'
    response.headers["date"] = DateTime.now.to_s
end

cluster = ClusterHelper.new()

namespace '/api/v1' do
  get '/crimes' do
      querySet = params[:q].nil? ? [] : params[:q].split('=')
      if querySet.length == 0
        response = DAO.new(cluster).getAll()
        paginateResponse(response,"crimes")
    elsif isValidQueryLength(querySet) && isValidQueryFields(querySet)
        response = DAO.new(cluster).getByQuerySet(querySet)
        paginateResponse(response,"crimes")
    else
        description = isValidQueryFields(querySet) ? "Invalid number of query parameters. Only single field query is allowed" : "#{querySet[0]} field is not queryable"
        status 400
        {:"error" => {:"status" => 400, :"description" => "#{description}"}}.to_json
    end
  end
  
  get '/crimes/:id' do |id|
    resource = DAO.new(cluster).getById(id)
    if resource.empty?
        status 404
        {:"error" => {:"status" => 404, :"description" => "Resoure not found"}}.to_json
    else 
        {:"crime" => resource.first}.to_json
    end
  end

end

def paginateResponse(apiResponse,apiKey)
    if apiResponse.empty?
        status 404
        {:"error" => {:"status" => 404, :"description" => "Resoure not found"}}.to_json
    else 
        page              = params[:page] || 1
        limit             = params[:limit] || 250
        full_data         = apiResponse
        page_data         = full_data.paginate(:page => page, :per_page => limit)
        {
            :"#{apiKey}"      => page_data,
            :count            => page_data.count,
            :total_records    => full_data.count,
            :current_page     => page_data.current_page,
            :per_page         => limit,
            :total_pages      => page_data.total_pages
        }.to_json
    end
end

def isValidQueryLength(querySet)
     querySet.length == 2
end

def isValidQueryFields(querySet)
    queryableFields = ['dc_key','dc_dist','dispatch_date','location_block','text_general_code','ucr_general']
    queryableFields.include? querySet[0].gsub(/\s/,'')
end

error 500..599 do
    {:"error" => {:"status" => 500, :"description" => env['sinatra.error'].message}}.to_json
end
