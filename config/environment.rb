require 'bundler'
Bundler.require
require "pry"

module Concerns
end

require_all 'lib'

class Song
  attr_accessor :name, :artist, :genre
  @@all = []

  def initialize(name, artist = nil, genre = nil)
    self.genre = genre
    self.artist = artist
    @name = name
    save
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create(title)
    created_song = self.new(title)
  end

  def self.destroy_all
    @@all.clear
  end

  def artist=(artist)
    if self.artist.nil?
      @artist = artist
    end
    if !self.artist.nil?
      artist.add_song(self)
    end
  end

  def genre=(genre)
    if self.genre.nil?
      @genre = genre
    end
    if !self.genre.nil?
      genre.songs << self unless genre.songs.include?(self)
    end
  end

  def self.find_by_name(name)
    self.all.find {|song| song.name == name}
  end

  def self.find_or_create_by_name(name)
    if self.find_by_name(name) == nil
      self.create(name)
    else
      self.find_by_name(name)
    end
  end

  def self.create_from_filename(file)
    @@all << self.new_from_filename(file)
  end

  def self.new_from_filename(file)
    split_song = file.chomp(".mp3").split(" - ")
    new_song = split_song[1]
    new_song_artist = split_song[0]
    new_song_genre= split_song[2]
    song = self.find_or_create_by_name(new_song)
    song.artist = Artist.find_or_create_by_name(new_song_artist)
    song.genre = Genre.find_or_create_by_name(new_song_genre)
    song
  end

end

class Artist

  extend Concerns::Findable

  attr_accessor :name
  @@all = []

  def initialize(name)
    @name = name
    @songs = []
    save
  end

  def songs
    @songs
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end

  def add_song(song)
    if song.artist == nil
      song.artist = self
      if !self.songs.include?(song)
        self.songs << song
      end
    end
  end

  def self.create(artist_x)
    created_artist = self.new(artist_x)
  end

  def self.destroy_all
    @@all.clear
  end

#self, self.songs are empty for some reason. there's nothing to be mapped???
def genres
  genres = @songs.collect do |song|
    song.genre
  end
  genres.uniq
end
=begin
  def genres
    array = []
    self.songs.map do |song|
      #binding.pry
       array << song.genre
       #binding.pry
    end
    array.uniq
    #binding.pry
  end
=end
end


class Genre

  extend Concerns::Findable

  attr_accessor :name
  @@all = []

  def initialize(name)
    @name = name
    @songs = []
    save
  end

  def songs
    @songs
  end

  def save
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create(genre_x)
    created_genre = self.new(genre_x)
  end

  def self.destroy_all
    @@all.clear
  end

  def artists
    array = []
    self.songs.map do |song|
      #binding.pry
      array << song.artist
       #binding.pry
    end
    array.uniq
    #binding.pry
  end

end


class MusicImporter

  attr_accessor :path
  def initialize(path)
    @path = path
  end

  def files
    files = []
    Dir.new(self.path).each do |file|
      files << file if file.length > 3
    end
    files
  end

  def import
    self.files.each do |filename|
      Song.create_from_filename(filename)
    end
  end

end

class MusicLibraryController
  attr_accessor :path, :m_i
  def initialize(path = './db/mp3s')
    @path = path
    @m_i = MusicImporter.new(path).import
  end

  def call
    input = " "
    while input != "exit"
      puts "Welcome to your music library!"
      puts "To list all of your songs, enter 'list songs'."
      puts "To list all of the artists in your library, enter 'list artists'."
      puts "To list all of the genres in your library, enter 'list genres'."
      puts "To list all of the songs by a particular artist, enter 'list artist'."
      puts "To list all of the songs of a particular genre, enter 'list genre'."
      puts "To play a song, enter 'play song'."
      puts "To quit, type 'exit'."
      puts "What would you like to do?"
      input = gets.strip

      case input
      when "list songs"
        list_songs
      when "list artists"
        list_artists
      when "list genres"
        list_genres
      when "list artist"
        list_songs_by_artist
      when "list genre"
        list_songs_by_genre
      when "play song"
        play_song
      end
    end
  end

#utilizes list_songs
#prompts user input and accepts user input
#checks that the user entered a number between one and the total number of songs in the library


  def play_song
    #input = " "
    puts "Which song number would you like to play?"
    #tunes = list_songs
    #binding.pry
    input = gets.strip.to_i
    if (input >= 1) && (input <= list_songs.length)
      #binding.pry
      #input = gets.strip.to_1
      song = list_songs[input -1]
      puts "Playing #{song.name} by #{song.artist.name}"
      binding.pry
    end
  end

=begin
  def list_songs_by_artist
    input = " "
    puts "Please enter the name of an artist:"
    input = gets.strip
    if artist = Artist.find_by_name(input) 
      artist.songs.sort{ |a, b| a.name <=> b.name }.each.with_index(1) do |s, i| 
      puts "#{i}. #{s.name} - #{s.genre.name}" 
      end 
    end
  end
=end


# Above is code from one of the instructors that does not work for me for whatever the hell reason!
# Below is my code that doesn't work, becasue the artist isn't being pushed inot the array.
=begin
  def list_songs_by_artist
    input = " "
    puts "Please enter the name of an artist:"
    input = gets.strip
    if artist_match = Artist.find_by_name(input)
      array = artist_match.songs.sort_by {|song| song.name}
      #binding.pry
      array.each.with_index(1) do |song, i|
      puts "#{i}. #{song.name} - #{song.genre.name}"
      #binding.pry
      end
    end
  end
=end


  def list_songs_by_genre
    num = 1
    input = " "
    puts "Please enter the name of a genre:"
    input = gets.strip
    if genre_match = Genre.find_by_name(input)
      array = genre_match.songs.sort_by {|song| song.name}
      array.each do |song|
        puts "#{num}. #{song.artist.name} - #{song.name}"
        num += 1
        #binding.pry
      end
    end
  end

  def list_songs
    #array = []
    num = 1
    array = Song.all.sort_by {|song| song.name}
    array.uniq.each do |song|
      puts "#{num}. #{song.artist.name} - #{song.name} - #{song.genre.name}"
      num += 1
    end
  end

  def list_artists
    #array = []
    num = 1
    array = Artist.all.sort_by {|artist| artist.name}
    array.each do |artist|
     puts "#{num}. #{artist.name}"
     num += 1
   end
 end

  def list_genres
    #array = []
    num = 1
    array = Genre.all.sort_by {|genre| genre.name}
    array.each do |genre|
      puts "#{num}. #{genre.name}"
      num += 1
    end
  end

end


#m_c = MusicLibraryController.new("./spec/fixtures/mp3s")
#m_c.play_song
