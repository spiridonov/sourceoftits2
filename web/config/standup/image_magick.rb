Standup.script :node do
  def run
    install_packages 'imagemagick libmagickwand-dev'
  end
end