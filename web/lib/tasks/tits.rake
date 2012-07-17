namespace :tits do

  desc 'Grab link from tweets of @SourceOfTits into db/published.txt'
  task :grab => :environment do
    require 'twitter'
    require 'net/http'

    user_name = 'sourceoftits'

    f = File.new("#{Rails.root}/db/published.txt", 'w')

    (1..16).each do |page|
      Twitter.user_timeline(user_name, :page => page, :count => 200).each do |tweet|
        if tweet.text =~ /(http:\/\/\S*)/
          uri = URI.parse($1)
          http = Net::HTTP.new(uri.host, uri.port)
          http.start() do |http|
            req = Net::HTTP::Get.new(uri.path)
            response = http.request(req)
            real_link = response['location']
            puts real_link
            f.write "#{tweet.created_at.to_i}|#{real_link}\n"
          end
        end
      end
    end

    f.close
  end

  desc 'Import already published tweets and current queue from text files'
  task :import => [:environment, 'tits:import:published', 'tits:import:pending', 'tits:distances']

  namespace :import do
    task :published do
      File.open("#{Rails.root}/db/published.txt", 'r').each_line do |line|
        if line =~ /(\d+)\|(.*)/
          begin
            time = Time.at($1.to_i)
            tits = Tits.new({ :link => $2, :published_at => time, :added_at => time, :state => :published })
            tits.process_image
            tits.save!
          rescue
            puts line
          end
        end
      end
    end

    task :pending do
      File.open("#{Rails.root}/db/pending.txt", 'r').each_line do |line|
        begin
          tits = Tits.new({ :link => line, :added_at => Time.now, :state => :pending })
          tits.process_image
          tits.save!
        rescue
          puts line
        end
      end
    end

    task :failed do
      File.open("#{Rails.root}/db/failed.txt", 'r').each_line do |line|
        if line =~ /(\d+)\|(.*)/
          begin
            time = Time.at($1.to_i)
            tits = Tits.new({ :link => $2, :published_at => time, :added_at => time, :state => :published })
            tits.process_image
            tits.calc_distances
            tits.save!
          rescue
            puts line
          end
        end
      end
    end

    task :reprocess do
      Tits.where(:fingerprint => '0000000000000000').each do |tits|
        begin
          puts tits.link
          tits.process_image
          tits.save!
        rescue Exception => e
          puts e.message
          retry
        end
      end
    end
  end

  desc 'Clean databases and uploaded files'
  task :clean => [:environment, 'tits:clean:redis', 'tits:clean:mongodb', 'tits:clean:uploads']

  namespace :clean do
    task :mongodb do
      Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)
    end

    task :redis do
      redis = Redis.new
      keys = redis.keys "distances:*"
      keys.each do |key|
        redis.del key
      end
    end

    task :uploads do
      require 'fileutils'

      FileUtils.rm_rf "#{Rails.root}/public/uploads"
    end
  end

  desc 'Calculate Humming distances between all hashes. O(n^2)'
  task :distances => [:environment, 'tits:clean:redis'] do
    redis = Redis.new

    fingerprints = Tits.all.each_with_object({}) { |tits, hash| hash[tits.id.to_s] = tits.fingerprint.hex }

    fingerprints.each_pair do |id1, fingerprint1|
      puts "#{id1} => #{fingerprint1}"
      fingerprints.each_pair do |id2, fingerprint2|
        next if id1 == id2
        distance = Phashion.hamming_distance(fingerprint1, fingerprint2)
        if distance <= Settings.hamming_threshold
          redis.zadd "distances:#{id1}", distance, id2
        end
      end
    end
  end

end