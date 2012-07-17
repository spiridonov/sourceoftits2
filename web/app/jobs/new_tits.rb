class NewTits
  @queue = :pending_tits

  def self.perform(link)
    return if Tits.where(:link => link).count > 0

    tits = Tits.new({ :added_at => DateTime.now, :link => link, :state => :pending })
    tits.process_image
    tits.calc_distances
    tits.save!
  end

end