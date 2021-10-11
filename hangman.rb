class Player
    attr_accessor :health, :guesses, :h_word
    attr_reader :word, :name
    def initialize(name, health = 6, guesses = [], word = self.choose_word)
        @name = name
        @health = health
        @guesses = guesses
        @word = word
        @h_word = @word.gsub(/[A-Za-z]/, '_').split('')
    end

    def choose_word
        file = File.open('5desk.txt')
        dictionary = file.readlines.map(&:chomp)
        dictionary.select! { |d| d.length.between?(5,12)}
        dictionary.sample
    end
end

def guess(player, hang_man)
    input = gets.chomp
    input.downcase!
    if ['quit', 'save', 'load', 'new'].include?(input)
        exit if input == 'quit'
        new_game(hang_man) if input == 'new'
        save(player, hang_man) if input == 'save'
        load(hang_man) if input == 'load'
        return 'quit'
    else
        return input if input.length == 1 && input.match?(/[a-z]/) && !player.guesses.include?(input)
        puts "Invalid guess. Your guess has to be a single letter that you have not guessed yet.\n\n"
        guess(player, hang_man)
    end
end

def check(guess, player, hang_man)
    player.guesses.push(guess)
    prev_guess = player.h_word
    indexes = player.word.split("").each_with_index.select {|i| player.word[i[1]].downcase == guess}
    if indexes.empty?
        player.health -= 1
    else
        indexes.each {|i| player.h_word[i[1]] = player.word[i[1]]}
    end
    puts "\n\n"
    puts "#{hang_man[6-player.health]}\n\n"
    puts "Word: #{player.h_word.join("")}"
    puts "Misses: #{(player.guesses - player.h_word).join(", ")} \n\n"
end

def save(player, hang_man)
    print 'Please choose save slot 1, 2 or 3: '
    slot = gets.chomp while ![1, 2, 3].include?(slot.to_i)
    binary = Marshal::dump(player)
    save = File.open("saves/#{slot}", 'w')
    save.puts binary
    puts 'Game saved!'
    save.close
    print "\n Type \"new\" to start a new game, \"load\" to load an unfinished game or \"quit\": "
    input = gets.chomp
    new_game(hang_man) if input == 'new'
    input == 'load' ? load(hang_man) : exit
end

def load(hang_man)
    print "Please choose save slot 1, 2 or 3: "
    slot = gets.chomp while ![1, 2, 3].include?(slot.to_i)
    pl = Marshal::load(File.open("saves/#{slot}", "r"){|f| f.read})
    player = Player.new(pl.name, pl.health, pl.guesses, pl.word)
    player.word.split("").each_with_index {|l, i| player.h_word[i] = player.word.split("")[i] if player.guesses.include?(l)}
    puts "Welcome back #{player.name}\n\n"
    puts "#{hang_man[6-player.health]}\n\n"
    puts "Word: #{player.h_word.join("")}"
    puts "Misses: #{(player.guesses - player.h_word).join(", ")} \n\n"
    play(player, hang_man)
end

def new_game(hang_man)
    print "Enter your name: "
    player = Player.new(gets.chomp)
    puts 'Type commands "quit","save","load" or "new" any time you need them'
    play(player, hang_man)
end

def play(player, hang_man)
    guess = ""
    while player.health > 0 && player.word != player.h_word.join("")
        print "Make a guess: "
        guess = guess(player, hang_man)
        break if guess == "quit"
        check(guess, player, hang_man)
    end
    if guess != "quit"
        puts (player.health > 0 ? "Congratulations, you win!" : "Game Over") 
        print "Play again?"
        input = gets.chomp
        new_game(hang_man) if ['yes', 'y', 'okay', 'ok', 'sure'].include?(input)
    end
end
hang_man = ["
    +---+
    |   |
        |
        |
        |
        |",
  "
    +---+
    |   |
    O   |
        |
        |
        |",
   "
    +---+
    |   |
    O   |
    |   |
        |
        |",
   "
    +---+
    |   |
    O   |
   /|   |
        |
        |",
   '
    +---+
    |   |
    O   |
   /|\  |
        |
        |',
   '
    +---+
    |   |
    O   |
   /|\  |
   /    |
        |',
  '
    +---+
    |   |
    O   |
   /|\  |
   / \  |
        |'
  ]

new_game(hang_man)




