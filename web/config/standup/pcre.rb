Standup.script :node do
  self.description = 'builds PRCE lib for nginx (required for outdated passenger gem)'
  
  PCRE_VERSION = "8.30"

  def run
    file_name = "pcre-#{PCRE_VERSION}"
    tarball_url = "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/#{file_name}.tar.gz"

    #TODO check version, specify it in standup config file
    unless installed?
      in_temp_dir do
        exec "wget #{tarball_url}"
        exec "tar xvfz #{file_name}.tar.gz"
        exec "cd #{file_name} && ./configure"
        exec "cd #{file_name} && make"
        exec "cd #{file_name} && sudo make install"
      end
    end

  end

  #add check for existed version
  def installed?
    false
  end
end
