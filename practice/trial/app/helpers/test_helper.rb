module TestHelper
# This might be trash! Source: https://gist.github.com/mitfik/3169039

  def s3_form_tag(options = {}) 
    bucket            = options[:bucket]
    access_key_id     = options[:access_key_id]
    secret_access_key = options[:secret_access_key]
    key               = options[:key] || ''
    content_type      = options[:content_type] || '' # Defaults to binary/octet-stream if blank
    redirect          = options[:redirect] || '/' 
    acl               = options[:acl] || 'public-read'
    expiration_date   = options[:expiration_date].strftime('%Y-%m-%dT%H:%M:%S.000Z') if options[:expiration_date]
    max_filesize      = options[:max_filesize] || 671088640 # 5 gb
    submit_button     = options[:submit_button] || '<input type="submit" value="Upload">'

    options[:form] ||= {}
    options[:form][:id] ||= 'upload-form'
    options[:form][:class] ||= 'upload-form'

    policy = Base64.encode64(
      "{'expiration': '#{expiration_date}',
        'conditions': [
          {'bucket': '#{bucket}'},
          ['starts-with', '$key', '#{key}'],
          {'acl': '#{acl}'},
          {'success_action_redirect': '#{redirect}'},
          ['starts-with', '#{content_type}', ''],
          ['content-length-range', 0, #{max_filesize}]
        ]
      }").gsub(/\n|\r/, '') 

      signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_access_key, policy)).gsub("\n","")
      out = ""
      out << %(
        <form action="https://#{bucket}.s3.amazonaws.com/" method="post" enctype="multipart/form-data" id="#{options[:form][:id]}" class="#{options[:form][:class]}" style="#{options[:form][:style]}">
        <input type="hidden" name="key" value="#{key}">
        <input type="hidden" name="AWSAccessKeyId" value="#{access_key_id}">
        <input type="hidden" name="acl" value="#{acl}">
        <input type="hidden" name="success_action_redirect" value="#{redirect}">
        <input type="hidden" name="policy" value="#{policy}">
        <input type="hidden" name="signature" value="#{signature}">
        <input name="file" type="file">#{submit_button}
        </form>
      )
  end
end
