require 'sinatra'
require 'sinatra/contrib/all'
require 'zip/zip'
require 'pry'

#configure do
#  set :haml, {:format => :html5, :escape_html => true}
#  set :scss, {:style => :compact, :debug_info => false}
#  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.rb'))
#end
#
#get '/stylesheets/:name.css' do
#  content_type 'text/css', :charset => 'utf-8'
#  scss(:"stylesheets/#{params[:name]}" )
#end

module Locksmith
  class App < Sinatra::Base
    register Sinatra::Contrib

    get '/' do
      haml :index
    end

    # SSHKey.generate(:type => "DSA", :bits => 1024, :comment => "foo@bar.com", :passphrase => "foobar")
    post '/download' do
      redirect '/' unless params[:passphrase]

      passphrase = params[:passphrase]
      passphrase = nil if  passphrase == ""

      k = SSHKey.generate(:type => "DSA", :bits => 1024, :passphrase => passphrase)

      stringio = Zip::ZipOutputStream::write_buffer do |zio|
        zio.put_next_entry("id_dsa.pub")
        zio.write k.ssh_public_key
        zio.put_next_entry("id_dsa")
        zio.write k.encrypted_private_key
      end
      stringio.rewind
      content_type 'application/zip'
      attachment 'ssh_key.zip'
      stringio
    end
  end
end
