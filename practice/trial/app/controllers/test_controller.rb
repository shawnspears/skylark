require 's3'

class TestController < ApplicationController

  def show
  	@service = S3::Service.new(:access_key_id => "ASIAIFHJYKN3BPV2KBVQ",
                          :secret_access_key => "l9ifQ40zsSkh7cw7QPmICBz6J8c2oxMad3ZZsJsB")
  end


end
