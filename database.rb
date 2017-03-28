require 'csv'
require 'erb'
require 'awesome_print'

class Person
  attr_reader "name", "phone_number", "address", "position", "salary", "slack_acct", "github_acct"

  def initialize(name, phone_number, address, position, salary, slack_acct, github_acct)
    @name = name
    @phone_number = phone_number.to_i
    @address = address
    @position = position
    @salary = salary.to_i
    @slack_acct = slack_acct
    @github_acct = github_acct
  end
end

class Database
  attr_reader "search_name"

  def initialize
    @person_array = []
    @tiy_database_file = "employees.csv"
    CSV.foreach(@tiy_database_file, headers: true) do |row|
      name = row["Name"]
      phone_number = row["Phone Number"]
      address = row["Address"]
      position = row["Position"]
      salary = row["Salary"]
      slack_acct = row["Slack Account"]
      github_acct = row["GitHub Account"]

      person = Person.new(name, phone_number, address, position, salary, slack_acct, github_acct)

      @person_array << person
    end
  end

  def add_person
    print "Please input a name: "
    name = gets.chomp

    if @person_array.find { |person| person.name == name }
      puts
      puts "#{name} is alredy in our system."
    else
      print "Input a phone number with area code, eg. 7278475464: "
      phone_number = gets.chomp.to_i

      print "Input the address, eg. 260 1st Ave S, St. Petersburg, FL 33701: "
      address = gets.chomp

      print "Input the position, eg. Instructor, Student, TA, or Campus Director: "
      position = gets.chomp

      print "Input the salary: "
      salary = gets.chomp.to_i

      print "Input the Slack account: "
      slack_acct = gets.chomp

      print "Input the GitHub account: "
      github_acct = gets.chomp

      person = Person.new(name, phone_number, address, position, salary, slack_acct, github_acct)

      @person_array << person
    end

  end

  def search_person
    print "Please input the username of their Slack, GitHub account or the name of the person you want to search: "
    search_person = gets.chomp

    multiple_persons = @person_array.find_all {|x| (x.name.include?(search_person)) || (x.slack_acct.include?(search_person)) || (x.github_acct.include?(search_person))}

    if multiple_persons.empty?
      puts
      puts "The search for \"#{search_person}\", yielded zero results."
    else
      puts
      puts "Here are the results of your search including: #{search_person}."
      puts
      multiple_persons.each do |person|
        puts "Name: #{person.name}".ljust(20) + "| Phone Number: #{person.phone_number}".ljust(27) + "| Adress: #{person.address}".ljust(50) + "| Position: #{person.position}".ljust(28) + "| Salary: $#{person.salary}".ljust(17) + "| Slack Account: #{person.slack_acct}".ljust(28) + "| GitHub Account: #{person.github_acct}"
      end
    end
  end

  def delete_person
    puts
    print "Please input the name of the person you want to delete: "
    delete_person = gets.chomp

    if @person_array.any? { |person| person.name == delete_person}
      @person_array.delete_if { |person| person.name == delete_person}
      puts
      puts "Deleted person: #{delete_person}"
    else
      puts
      puts"#{delete_person} is not in our system."
    end
  end

  def report
    puts
    puts "Here is a list of the individuals associated with The Iron Yard."
    puts
    @person_array.each do |person|
      puts "Name: #{person.name}".ljust(20) + "| Phone Number: #{person.phone_number}".ljust(27) + "| Adress: #{person.address}".ljust(50) + "| Position: #{person.position}".ljust(28) + "| Salary: $#{person.salary}".ljust(17) + "| Slack Account: #{person.slack_acct}".ljust(28) + "| GitHub Account: #{person.github_acct}"
    end

    persons_by_position = @person_array.group_by { |person| person.position }

    persons_by_position.each do |position, people|
      total_salary = people.map { |person| person.salary }.sum
      puts
      puts "Here is the info for the #{position} position."
      puts "The total salary is: $ #{total_salary}."
      if people.count == 1
        puts "There is only 1 #{position}."
      else
        puts "There are #{people.count} #{position}s."
      end
    end
  end

  def write_file_csv
    CSV.open(@tiy_database_file, "w") do |row|
      row << ["Name", "Phone Number", "Address", "Position", "Salary", "Slack Account", "GitHub Account"]
      @person_array.each do |person|
        row << [person.name, person.phone_number, person.address, person.position, person.salary, person.slack_acct, person.github_acct]
      end
    end
  end

  def write_file_html
    template = ERB.new(File.read("report.html.erb"))
    html = template.result(binding)

    File.write("report.html", html)
  end

  def write_file_txt
    template = ERB.new(File.read("report.txt.erb"))
    txt = template.result(binding)

    File.write("report.txt", txt)
  end
end

class Menu
  def initialize
    @database = Database.new
    @menu = true
  end

  def menu_selection
    while @menu == true
      puts
      puts "Please type what you would like to do:"

      puts
      puts "\tA: Add a person"
      puts "\tS: Search for a person"
      puts "\tD: Delete a person"
      puts "\tR: Report"
      puts "\tQ: Quit"
      print ">> "
      selected = gets.chomp.downcase
      puts

      if selected == "a"
        @database.add_person
        @database.write_file_csv
      elsif selected == "s"
        @database.search_person
      elsif selected == "d"
        @database.delete_person
        @database.write_file_csv
      elsif selected == "r"
        puts
        puts "Would like you like to see the report on screen or in a browser?"
        puts
        puts "\tS: On screen"
        puts "\tB: Browser"
        puts "\tT: Text"
        print ">> "
        report = gets.chomp.downcase
        if report == "s"
          @database.report
        elsif report == "b"
          puts
          puts "The report has been saved to a HTML file."
          @database.write_file_html
        elsif report == "t"
          puts
          puts "The report has been saved to a TEXT file."
          @database.write_file_txt
        else
          puts
          puts "Please choose one of the correct options please."
        end
      elsif selected == "q"
        @menu = false
        puts "Thank you for your input."
        puts
        @database.write_file_html
      else
        puts "Please only select: A | S | D | Q"
      end
    end
  end
end

instance = Menu.new

instance.menu_selection
