class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :create]

  def new
    @image = Image.new()
  end

  def create
    # params -> :file
    # We are going to upload the image to this controller from a form

    # 2. Get AWS credentials from mapwhatever
    # 3. Upload the image to AWS
    # 4. Post to mapwhatever with the image url and tile and whatever else it needed
    Image.create(image_params)
  end


  private

    def image_params
      params.require(:image).permit(:image_url)
    end

    def set_image
      @image = Image.find(params[:id])
    end

    def set_s3_direct_post
      response = HTTParty.get('https://api.mapbox.com/uploads/v1/f-ocal/credentials?access_token=sk.eyJ1IjoiZi1vY2FsIiwiYSI6ImNpa3ZneGFpYzAwZnV1bWtzczA2YWQ5OTQifQ.Eqezri-fTOcuCfv_mMTCuw')

      # access_key = response.parsed_response["accessKeyId"] # "ASIAJIVVQ6O6LAUW37YA"
      # secret_access_key_id = response.parsed_response["secretAccessKey"] # "av2oTF7g6Tr/NhrnGFmDOEV9zzKJ1ALHgq+Gl200"

      secretAccessKey = response.parsed_response["secretAccessKey"] # "ASIAJIVVQ6O6LAUW37YA"
      accessKeyId = response.parsed_response["accessKeyId"] #

      key = response.parsed_response['key'] # "cc/_pending/cq9utvv03mgu4g00er7ygvkic/f-ocal"
      @bucket = response.parsed_response["bucket"] # "tilestream-tilesets-production"

      # @s3_bucket = Aws::S3::Resource.new({
      #   region: 'us-east-1',
      #   credentials: Aws::Credentials.new(access_key, secret_access_key_id)
      # }).bucket(response.parsed_response["bucket"]).object(key)

      Aws.config.update({
        region: 'us-east-1',
        credentials: Aws::Credentials.new(access_key, secret_access_key_id)
      })

      @s3_bucket = Aws::S3::Resource.new.bucket(@bucket)

      # Aws.config[:http_wire_trace] = true
      # Aws.config[:region] = 'us-west-2'

      # this is the file location you'll save to in AWS
      #<Aws::S3::Object bucket_name="tilestream-tilesets-production", key="cc/_pending/cq9utvv03mgu4g00er7ygvkic/f-ocal">

      # upload the file here

      @s3_direct_post = @s3_bucket.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')

      @s3_bucket.upload_file './sample.tif' # path to the file you want to upload
    end

end

# class ImagesController < ApplicationController
#   before_action :set_image, only: [:show, :edit, :update, :destroy]
#   before_action :set_s3_direct_post, only: [:new, :create]
#
#   def new
#     @image = Image.new()
#   end
#
#   def create
#     # params -> :file
#     # We are going to upload the image to this controller from a form
#
#     # 2. Get AWS credentials from mapwhatever
#     # 3. Upload the image to AWS
#     # 4. Post to mapwhatever with the image url and tile and whatever else it needed
#     Image.create(image_params)
#   end
#
#
#   private
#
#     def image_params
#       params.require(:image).permit(:image_url)
#     end
#
#     def set_image
#       @image = Image.find(params[:id])
#     end
#
#     def set_s3_direct_post
#       response = HTTParty.get('https://api.mapbox.com/uploads/v1/f-ocal/credentials?access_token=pk.eyJ1IjoiZi1vY2FsIiwiYSI6ImNpa3RicHY1ZTAwNTZ1OWtzejkxYW1neW4ifQ.h3BMTWeux-eUfSRL2TfL8Q')
#
#       access_key = response.parsed_response["accessKeyId"]
#       secret_access_key_id = response.parsed_response["secretAccessKey"]
#       @bucket = response.parsed_response["bucket"]
#
      # Aws.config.update({
        # region: 'us-east-1',
        # credentials: Aws::Credentials.new(access_key, secret_access_key_id)
      # })

      # @s3_bucket = Aws::S3::Resource.new( region: 'us-east-1',
                                          # credentials:      Aws::Credentials.new(access_key, secret_access_key_id)).bucket(response.parsed_response["bucket"]).object 'temp'
#
#
#
#       # @s3_bucket.upload_file './sample.tif' # path to the file you want to upload
#
#       @s3_direct_post = @s3_bucket.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
#
#       p @s3_bucket
#     end
#
# end
