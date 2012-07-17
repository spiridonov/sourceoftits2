Standup.script :node do
  self.description = 'Update web application'
  
  def run
    in_dir scripts.webapp.project_path do
      sudo 'chown -R ubuntu:ubuntu .'

      exec 'git checkout HEAD .'
      exec 'git pull'

      scripts.webapp.checkout_branch

      sudo "chown -R www-data:www-data ."
    end

    update_webapp

    #compile_assets

    scripts.webapp.restart
  end
  
  protected
  
  def update_webapp
    scripts.webapp.install_gems
  end

  def compile_assets
    in_dir scripts.webapp.app_path do
      sudo 'rake assets:clean'
      sudo 'rake assets:precompile'
    end    
  end
end
