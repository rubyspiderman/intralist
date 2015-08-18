namespace :preload_themes do
  desc 'create themes'
  task :load_themes => :environment do
    image1 = File.open('app/assets/images/themes/camo_background.png')
    theme1 = ProfileTheme.create!(:name => 'Desert Camo',
                                 :background_image => image1)

    image2 = File.open('app/assets/images/themes/ArabTile.jpg')
    theme2 = ProfileTheme.create!(:name => 'Arab Tile',
                                 :background_image => image2)
    image3 = File.open('app/assets/images/themes/Escheresque.jpg')
    theme3 = ProfileTheme.create!(:name => 'Escheresque',
                                :background_image => image3)

    image4 = File.open('app/assets/images/themes/FoggyBirds.jpg')
    theme4 = ProfileTheme.create!(:name => 'Foggy Birds',
                               :background_image => image4)
    image5 = File.open('app/assets/images/themes/Graphy.jpg')
    theme5 = ProfileTheme.create!(:name => 'Graphy',
                                :background_image => image5)
    image6 = File.open('app/assets/images/themes/GreyFloral.jpg')
    theme6 = ProfileTheme.create!(:name => 'Grey Floral',
                                 :background_image => image6)
   image7 = File.open('app/assets/images/themes/LightHoneycomb.jpg')
   theme7 = ProfileTheme.create!(:name => 'Light Honeycomb',
                                :background_image => image7)

  image8 = File.open('app/assets/images/themes/LittlePluses.jpg')
  theme8 = ProfileTheme.create!(:name => 'Little Pluses',
                               :background_image => image8)
   image9 = File.open('app/assets/images/themes/NoisyGrid.jpg')
   theme9 = ProfileTheme.create!(:name => 'Noisy Grid',
                                :background_image => image9)
  image10 = File.open('app/assets/images/themes/PinstripeSuit.jpg')
  theme10 = ProfileTheme.create!(:name => 'Pinstripe Suit',
                              :background_image => image10)
  image11 = File.open('app/assets/images/themes/PWMazeWhite.jpg')
  theme11 = ProfileTheme.create!(:name => 'Maze White',
                               :background_image => image11)
  image12 = File.open('app/assets/images/themes/Shattered.jpg')
  theme12 = ProfileTheme.create!(:name => 'Shattered',
                              :background_image => image12)

  image13 = File.open('app/assets/images/themes/StrangeBullseyes.jpg')
  theme13 = ProfileTheme.create!(:name => 'Strange Bullseyes',
                             :background_image => image13)
  image14 = File.open('app/assets/images/themes/Wavecut.jpg')
  theme14 = ProfileTheme.create!(:name => 'Wave Cut',
                              :background_image => image14)
                              
  image15 = File.open('app/assets/images/themes/WoodTexture.jpg')
  theme15 = ProfileTheme.create!(:name => 'Wood Texture',
                             :background_image => image15)
  image16 = File.open('app/assets/images/themes/Woven.jpg')
  theme16 = ProfileTheme.create!(:name => 'Woven',
                              :background_image => image16)

  end
end
