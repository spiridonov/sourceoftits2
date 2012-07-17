class ProcessTits
  @queue = :process_tits

  def self.perform
    tits = Tits.approved.first
    tits.publish! if tits
  end

end