require 'net/http'
require 'uri'

class Tits
  include Mongoid::Document
  include Mongoid::Symbolize

  field :link, :type => String
  field :published_at, :type => DateTime
  field :added_at, :type => DateTime
  mount_uploader :preview, PreviewUploader
  symbolize :state, :in => [:pending, :published, :approved, :rejected], :default => :pending
  field :fingerprint, :type => String
  field :size

  scope :pending, where(:state => :pending).asc(:added_at)
  scope :published, where(:state => :published).desc(:published_at)
  scope :approved, where(:state => :approved).asc(:added_at)
  scope :rejected, where(:state => :rejected).asc(:added_at)

  def pending?
    state == :pending
  end

  def rejected?
    state == :rejected
  end

  def approved?
    state == :approved
  end

  def published?
    state == :published
  end

  def publish!
    return unless approved?

    Twitter.update(link)
    update_attribute(:state, :published)
  end

def process_image
  uri = URI.parse(self.link)
  http = Net::HTTP.new(uri.host, uri.port)
  http.start() do |http|
    req = Net::HTTP::Get.new(uri.path)
    response = http.request(req)
    tempfile = Tempfile.new(File.basename(uri.path))
    begin
      File.open(tempfile.path, 'wb') { |f| f.write response.body }

      if File.extname(uri.path) =~ /\.png/i
        thumb = Magick::Image.read(tempfile.path).first
        thumb.format = 'JPEG'
        thumb.write tempfile.path
      end

      phasion = Phashion::Image.new(tempfile.path)
      self.fingerprint = '%016x' % phasion.fingerprint
      self.preview = tempfile
      self.preview.store!
      self.size = tempfile.size
    ensure
      tempfile.close
      tempfile.unlink
    end
  end
end

def calc_distances(two_way=true)
  Tits.where(:_id.ne => id).each do |tits|
    distance = Phashion.hamming_distance(fingerprint.hex, tits.fingerprint.hex)
    if distance <= Settings.hamming_threshold
      redis.zadd "distances:#{id}", distance, tits.id
      redis.zadd "distances:#{tits.id}", distance, id if two_way
    end
  end
end


  def similarities(&block)
    s = redis.zrange "distances:#{id}", 0, -1
    s.each do |similarity_id|
      tits = Tits.find(similarity_id)
      yield tits
    end
    nil
  end

  protected

  def redis
    @redis ||= Redis.new
  end

end
