require 'rubygems' # necessary for ruby v1.8.*
require 'lifx'
require 'micro-optparse'

options = Parser.new do |p|
	p.banner = "Lifx HSL Help:"
	p.banner = "Usage: ruby lifx-hsl.rb [arguments]"
	p.version = "Lifx HSL 0.1 alpha."
	p.option :name, "Name of the bulb to change.", :default => ''
	p.option :HUE, "Set color in HUE value, between 0.0 and 360.0.", :default => 170, :value_satisfies => lambda {|x| x >= 0.0 && x <= 360.0}
	p.option :saturation, "Set the saturation value, between 0.0 and 1.0.", :default => 0.9, :value_satisfies => lambda {|x| x >= 0.0 && x <= 1.0}
	p.option :lightness, "Set the lightness value, between 0.0 and 1.0.", :default => 0.5, :value_satisfies => lambda {|x| x >= 0.0 && x <= 1.0}
	p.option :duration, "Set the color fade, in seconds.", :default => 4, :value_satisfies => lambda {|x| x >= 0}
	p.option :off, "Turn light off after color change", :default => 0, :value_in_set => [0,1]
	# p.option :verbose, "Enable verbose output"
end.process!

raise ArgumentError, "Please add bulb name with the -n argument!" unless options[:name].size > 0

print("------------------------------------------------------\n")
print("Discovering bulb…\n")
client = LIFX::Client.lan
begin
	client.discover! do |c|
		c.lights.with_label(options[:name])
	end
	print("Bulb(#{options[:name]}) discovered\n")
rescue Exception => e
	print("Could not find bulb(#{options[:name]})\n")
	puts e.message
	exit
end

client.lights.turn_on
light = client.lights.with_label(options[:name])
print("#{client.lights}\n")

print("Start color change\n")
light.set_color(LIFX::Color.hsl(options[:HUE], options[:saturation], options[:lightness]), duration: options[:duration])

sleep options[:duration]
print("Color has changed\n")

if options[:off] == 1
	client.lights.turn_off
end
print("------------------------------------------------------\n")

client.flush