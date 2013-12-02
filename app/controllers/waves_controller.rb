class WavesController < ApplicationController
  
  def new
    
  end
  
  def generate
    samples = if request.get?
      Base64.decode64( params[:samples] ).split(/,/).collect(&:to_f)
    else
      params[:samples].collect(&:to_f)
    end
    
    filename = Rails.root.join('tmp', 'square.wav') # NOTE: Filename will be a UUID and will be deleted after sending
    format = WaveFile::Format.new(:mono, :pcm_16, 44100)
    
    WaveFile::Writer.new(filename, format) do |writer|
      buffer_format = WaveFile::Format.new(:mono, :float, 44100)
      
      if request.post?
        200.times do
          buffer = WaveFile::Buffer.new(samples, buffer_format)
          writer.write(buffer)
        end
      else
        buffer = WaveFile::Buffer.new(samples, buffer_format)
        writer.write(buffer)
      end
    end
    
    data = params[:base64] ? Base64.encode64(filename.read) : filename.read
    
    if request.post?
      send_data(data)
    else
      send_data(data, filename: 'wave.wav', type: 'audio/wav')
    end
  end
  
end
