require 'local_server'

describe "AsyncHttp" do

    after(:all) do
        file_name = File.join(Rho::RhoApplication::get_base_app_path(), 'test.jpg')
        File.delete(file_name) if File.exists?(file_name)

        file_name = File.join(Rho::RhoApplication::get_app_path('DataTemp'), 'test_log.txt')
        File.delete(file_name) if File.exists?(file_name)		
        
    end
    
    it "should http get" do
        res = Rho::AsyncHttp.get(
          :url => 'http://www.apache.org/licenses/LICENSE-2.0' )
        
        #puts "res : #{res}"  
        
        res['status'].should == 'ok'
        res['headers']['content-type'].should ==  'text/plain; charset=utf-8'
        res['body'].should_not be_nil

        # www.apache.org response with gzipped body if client declare 'Accept-Encoging: gzip'
        # (our network implementation for iPhone and Android does).
        # It means that content-length header will contain value less than
        # body length because body we have on application level is already decoded
        # This is why following two lines commented out
        #res['headers']['content-length'].should == 11358
        #res['body'].length.should == res['headers']['content-length'].to_i
        res['body'].length.should == 11358
    end

    it "should http post" do
        
        #TODO: post_test
    end
if !defined?(RHO_WP7)
    it "should http download" do

        file_name = File.join(Rho::RhoApplication::get_base_app_path(), 'test.png')
        File.delete(file_name) if File.exists?(file_name)
        File.exists?(file_name).should == false

        reference_url = 'http://www.google.com/images/icons/product/chrome-48.png'
        reference_size = 1834

        res = Rho::AsyncHttp.download_file(
          :url => reference_url,
          :filename => file_name )
        puts "res : #{res}"  
        
        res['status'].should == 'ok'
        res['headers']['content-length'].to_i.should == reference_size
        res['headers']['content-type'].should == 'image/png'

        File.exists?(file_name).should == true
        orig_len = File.size(file_name)
        orig_len.should == res['headers']['content-length'].to_i

        #delete file for re-download
        File.delete(file_name) if File.exists?(file_name)

        #check that in case of one more download, files keeps the same        
        res = Rho::AsyncHttp.download_file(
          :url => reference_url,
          :filename => file_name )
        puts "res : #{res}"  
        
        res['status'].should == 'ok'
        res['headers']['content-length'].to_i.should == reference_size
        res['http_error'].should == '200'
        #res['headers']['content-type'].should == 'image/png'

        File.exists?(file_name).should == true
        File.size(file_name).should == orig_len

        #check that in case of network error, files keeps the same        
        res = Rho::AsyncHttp.download_file(
          :url => 'http://www.google.com/images/icons/product/chrome-48_BAD.png',
          :filename => file_name )
        puts "res : #{res}"  
        res['status'].should == 'error'
        res['http_error'].should == '404'

        File.exists?(file_name).should == true
        File.size(file_name).should == orig_len
    end

    it "should http partial download" do
        file_name_source = File.join(Rho::RhoApplication::get_base_app_path(), 'testA')
        file_name_dest = File.join(Rho::RhoApplication::get_base_app_path(), 'testB')

        File.delete(file_name_source) if File.exists?(file_name_source)
        File.delete(file_name_dest) if File.exists?(file_name_dest)

        reference_url = 'http://yandex.st/jquery/cookie/1.0/jquery.cookie.min.js'
        reference_size = 732
        part_size = 366

        res = Rho::AsyncHttp.download_file(
          :url => reference_url,
          :headers => {"Accept-Encoding"=>""}, #disable any compression
          :filename => file_name_source )
        puts "res : #{res}"  
        
        res['status'].should == 'ok'
        res['headers']['content-length'].to_i.should == reference_size
        res['headers']['content-type'].should == 'application/x-javascript'

        File.exists?(file_name_source).should == true
        orig_len = File.size(file_name_source)
        orig_len.should == res['headers']['content-length'].to_i

        #if file was downloaded succesfully leave only part of it for a next test
        if orig_len == File.size(file_name_source)
          orig_part = open(file_name_source, "rb") {|io| io.read(part_size) }
          open(file_name_dest, "wb+") {|io| io.write(orig_part) }
          File.size(file_name_dest).should == part_size
        end

        #check that in case of re-download files are the same        
        res = Rho::AsyncHttp.download_file(
          :url => reference_url,
          :headers => {"Accept-Encoding"=>""}, #disable any compression
          :filename => file_name_dest )
        puts "res : #{res}"  
        
        res['status'].should == 'ok'
        res['headers']['content-length'].to_i.should == (reference_size - part_size)
        res['http_error'].should == '206'

        File.exists?(file_name_dest).should == true
        File.size(file_name_dest).should == orig_len

        file_a = open(file_name_source, "rb") {|io| io.read() }
        file_b = open(file_name_dest, "rb") {|io| io.read() }

        (file_a <=> file_b).should == 0
    end
end
    it "should http upload" do
        
        server = 'http://rhologs.heroku.com'
        
        file_name = File.join(Rho::RhoApplication::get_app_path('DataTemp'), 'test_log.txt')
        File.exists?(file_name).should ==  true

        res = Rho::AsyncHttp.upload_file(
          :url => server + "/client_log?client_id=&device_pin=&log_name=uptest",
          :filename => file_name )
        #puts "res : #{res}"  
        
        res['status'].should == 'ok'
        File.exists?(file_name).should ==  true
    end

    it "should http upload" do
        
        server = 'http://rhologs.heroku.com'
		dir_name = Rho::RhoApplication::get_app_path('DataTemp')
		Dir.mkdir(dir_name) unless Dir.exists?(dir_name)
        
        file_name = File.join(dir_name, 'test_log.txt')
        puts " file_name : #{file_name}"
        File.open(file_name, "w"){|f| puts "OK"; f.write("******************THIS IS TEST! REMOVE THIS FILE! *******************")}

        res = Rho::AsyncHttp.upload_file(
          :url => server + "/client_log?client_id=&device_pin=&log_name=uptest",
          :filename => file_name )
          #optional parameters:
          #:filename_base => "phone_spec_file",
          #:name => "phone_spec_name" )
        
        res['status'].should == 'ok'
        File.exists?(file_name).should ==  true
    end

    it "should decode chunked body" do

      host = SPEC_LOCAL_SERVER_HOST
      port = SPEC_LOCAL_SERVER_PORT
      puts "+++++++++++++++++++ chunked test: #{host}:#{port}"
      res = Rho::AsyncHttp.get :url => "http://#{host}:#{port}/chunked"
      res['status'].should == 'ok'
      res['body'].should_not be_nil
      res['body'].should == "1234567890"
    end

    it "should send custom command" do
        
        res = Rho::AsyncHttp.get(
          :url => 'http://www.apache.org/licenses/LICENSE-2.0',
          :http_command => 'PUT' )
        
        #puts "res : #{res}"  
        res['http_error'].should == '405'
        res['body'].index('The requested method PUT is not allowed for the URL').should_not be_nil
        
        res = Rho::AsyncHttp.post(
          :url => 'http://www.apache.org/licenses/LICENSE-2.0',
          :http_command => 'PUT' )
        
        #puts "res : #{res}"  
        res['http_error'].should == '405'
        res['body'].index('The requested method PUT is not allowed for the URL').should_not be_nil
        
    end    

    it "should upload with body" do
        
        server = 'http://rhologs.heroku.com'
        
        file_name = File.join(Rho::RhoApplication::get_app_path('app'), 'Data/test_log.txt')
        File.open(file_name, "w"){|f| f.write("******************THIS IS TEST! REMOVE THIS FILE! *******************")}

        res = Rho::AsyncHttp.upload_file(
          :url => server + "/client_log?client_id=&device_pin=&log_name=uptest",
          :filename => file_name,
          :file_content_type => "application/octet-stream",
          :filename_base => "phone_spec_file",
          :name => "phone_spec_name",
          
          :body => "upload test",
          :headers => {"content-type"=>"plain/text"}
           )
        #puts "res : #{res}"  
        
        res['status'].should == 'ok'
        File.exists?(file_name).should == true
    end

    it "should upload miltiple" do
        
        server = 'http://rhologs.heroku.com'
        
        file_name = File.join(Rho::RhoApplication::get_app_path('app'), 'Data/test_log.txt')
        File.open(file_name, "w"){|f| f.write("******************THIS IS TEST! REMOVE THIS FILE! *******************")}

        res = Rho::AsyncHttp.upload_file(
          :url => server + "/client_log?client_id=&device_pin=&log_name=uptest",
          :multipart => [
              { 
                :filename => file_name,
                :filename_base => "phone_spec_file",
                :name => "phone_spec_name",
                :content_type => "application/octet-stream"
              },
              {
                :body => "upload test",
                :name => "phone_spec_bodyname",
                :content_type => "plain/text"
              }
           ]
        )
        #puts "res : #{res}"  
        
        res['status'].should == 'ok'
        File.exists?(file_name).should == true
    end

    it "should send https request" do
            
        res = Rho::AsyncHttp.get(
          :url => 'https://rhologs.heroku.com' )
        
        puts "res : #{res}"  
        
        res['status'].should == 'ok'
        
        http_error = res['http_error'].to_i if res['http_error']
        if http_error == 301 || http_error == 302 #redirect
            res2 = Rho::AsyncHttp.get( :url => res['headers']['location'] )
            
            res2['status'].should == 'ok'
        end    
        
    end

end    
